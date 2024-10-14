defmodule BillionOak.Ingestion.Mannatech do
  alias BillionOak.{Repo, Customer, Filestore}
  alias BillionOak.Ingestion.Attempt
  use OK.Pipe

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
      ~> Stream.each(fn attrs_chunk ->
        {:ok, _} = Customer.create_or_update_accounts(organization, attrs_chunk)
      end)
      ~> Stream.run()

    case result do
      {:ok, _} = success ->
        mark_succeeded!(attempt)
        success
      {:error, _} = error ->
        mark_failed!(attempt)
        error
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
end
