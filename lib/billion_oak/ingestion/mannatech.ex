defmodule BillionOak.Ingestion.Mannatech do
  require Logger
  use OK.Pipe
  alias BillionOak.{Repo, Customer, Filestore}
  alias BillionOak.Ingestion.Attempt

  def ingest_accounts(org_handle, basename) do
    {:ok, company} = Customer.get_company("mannatech")
    {:ok, organization} = Customer.get_organization(company.id, org_handle)
    s3_key = s3_key(company.handle, org_handle, basename)
    attempt = mark_started!(organization, s3_key)

    result =
      {:ok, s3_key}
      ~>> Filestore.stream_s3_file()
      ~> CSV.decode(headers: true, separator: ?\t)
      ~> Stream.map(&account_attrs/1)
      ~> Stream.chunk_every(500)
      ~> Stream.map(fn attrs_chunk ->
        Customer.create_or_update_accounts(organization, attrs_chunk)
      end)
      ~> Stream.transform(nil, fn
        _, {:halt, n} ->
          {:halt, n}

        result, _ ->
          case result do
            {:ok, _} -> {[result], result}
            {:error, _} -> {[result], {:halt, result}}
          end
      end)
      ~>> Enum.reduce_while({:ok, 0}, fn
        {:error, reason}, {:ok, n} -> {:halt, {:error, n, reason}}
        {:ok, n}, {:ok, acc} -> {:cont, {:ok, acc + n}}
      end)

    case result do
      {:ok, _} ->
        mark_succeeded!(attempt)
        result

      {:error, n, details} ->
        Logger.warning("Ingestion partially succeeded for #{n} records, failed for the rest.")
        {index, error} = Enum.at(details, 0)
        Logger.warning("First error occurred at index #{index}: #{inspect(error)}")

        mark_failed!(attempt)
        result
    end
  end

  defp account_status("RECENT"), do: :active
  defp account_status("FORMER"), do: :inactive
  defp account_status("INACTIVE"), do: :inactive
  defp account_status("TERMINATED"), do: :terminated

  defp enrolled_at(date_str) do
    case Timex.parse(date_str, "{0M}/{0D}/{YYYY}") do
      {:ok, date} -> date
      _ -> nil
    end
  end

  defp account_attrs({:ok, row}) do
    %{
      status: account_status(row["STATUS"]),
      number: row["CTLNO"],
      name: row["NAME"],
      city: row["CITY"],
      state: row["STATE"],
      country_code: row["COUNTRY"],
      phone1: row["PHONENO"],
      phone2: row["EVPHONENO"],
      enrolled_at: enrolled_at(row["ENROLLMENTDATE"]),
      sponsor_number: row["SPONSORCTLNO"],
      enroller_number: row["ENROLLCTLNO"]
    }
  end

  defp s3_key(company_handle, org_handle, basename),
    do: "ingestion/#{company_handle}/#{org_handle}/mtku/#{basename}"

  defp mark_started!(organization, s3_key) do
    attrs = %{
      s3_key: s3_key,
      company_id: organization.company_id,
      organization_id: organization.id,
      format: "mtku"
    }

    %Attempt{}
    |> Attempt.changeset(attrs)
    |> Repo.insert!()
  end

  defp mark_succeeded!(attempt) do
    attempt
    |> Attempt.changeset(%{status: :succeeded})
    |> Repo.update!()
  end

  defp mark_failed!(attempt) do
    attempt
    |> Attempt.changeset(%{status: :failed})
    |> Repo.update!()
  end

  def unwrap({_, value}), do: value
end
