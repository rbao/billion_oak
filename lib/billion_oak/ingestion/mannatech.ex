defmodule BillionOak.Ingestion.Mannatech do
  alias BillionOak.{Repo, Customer, Filestore}
  alias BillionOak.Ingestion.Attempt
  use OK.Pipe

  def ingest_accounts(organization_alias, basename) do
    s3_key = s3_key(organization_alias, basename)
    attempt = mark_started!(organization_alias, s3_key)

    result =
      {:ok, s3_key}
      ~>> Filestore.stream_s3_file()
      ~> CSV.decode(headers: true, separator: ?\t)
      ~> Stream.map(&account_attrs/1)
      ~> Stream.each(fn attrs -> IO.inspect(attrs) end)
      |> Stream.chunk_every(500)
      |> Stream.each(fn attrs_chunk ->
        Customer.create_or_update_accounts(attrs_chunk)
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
      enrolled_at: enrolled_at(row["ENROLLMENTDATE"])
    }
  end

  defp s3_key(organization_alias, basename),
    do: "ingestion/#{organization_alias}/mtku/#{basename}"

  defp mark_started!(organization_alias, s3_key) do
    company = Customer.get_company!("mannatech")
    organization = Customer.get_organization!(organization_alias)

    attrs = %{
      s3_key: s3_key,
      company_id: company.id,
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
