defmodule BillionOak.Ingestion.Mannatech do
  alias BillionOak.{Customer, Filestore}

  def ingest_accounts(basename) do
    basename
    |> s3_key()
    |> Filestore.stream_s3_file()
    |> CSV.decode(headers: true, separator: ?\t)
    |> Stream.map(&account_params/1)
    |> Stream.each(fn params -> IO.inspect(params) end)
    # |> Stream.chunk_every(500)
    # |> Stream.each(fn params_chunk ->
    #   Customer.create_or_update_accounts(params_chunk)
    # end)
    |> Stream.run()
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

  defp s3_key(basename), do: "ingestion/mannatech/mtku/#{basename}"
end
