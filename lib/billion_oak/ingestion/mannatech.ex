defmodule BillionOak.Ingestion.Mannatech do
  alias BillionOak.{Customer, Filestore}
  use OK.Pipe

  def ingest_accounts(organization_alias, basename) do
    s3_key = s3_key(organization_alias, basename)

    {:ok, s3_key}
    ~>> Filestore.stream_s3_file()
    ~> CSV.decode(headers: true, separator: ?\t)
    ~> Stream.map(&account_params/1)
    ~> Stream.each(fn params -> IO.inspect(params) end)
    # |> Stream.chunk_every(500)
    # |> Stream.each(fn params_chunk ->
    #   Customer.create_or_update_accounts(params_chunk)
    # end)
    ~> Stream.run()
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

  defp account_params({:ok, row}) do
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

  defp s3_key(organization_alias, basename), do: "ingestion/#{organization_alias}/mtku/#{basename}"

  # Move Ingestion schema to Ingestion.Attempt
  defp start_ingestion(organization_alias, s3_key) do
    company = Customer.get_company!("mannatech")
    organization = Customer.get_organization!(organization_alias)

    ingestion_params = %{
      s3_key: s3_key,
      company_id: company.id,
      organization_id: organization.id,
      format: "mtku",
    }

    with {:ok, _} <- Customer.create_ingestion(ingestion_params) do
      Filestore.stream_s3_file(s3_key)
    else
      err -> err
    end
  end
end
