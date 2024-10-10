defmodule BillionOak.Ingestion.Mannatech do
  alias BillionOak.Customer

  def ingest_accounts(basename) do
    stream = stream_content(basename)

    stream
    |> CSV.decode(headers: true, separator: ?\t)
    |> Stream.chunk_every(500)
    |> Stream.map(&account_params/1)
    |> Stream.chunk_every(500)
    |> Stream.each(fn params_chunk ->
      Customer.create_or_update_accounts(params_chunk)
    end)
    |> Stream.run()
  end

  defp stream_content(basename) do
    bucket = System.fetch_env!("AWS_S3_BUCKET")
    key = "ingestion/mannatech/mtku/#{basename}"

    ExAws.S3.download_file(bucket, key, :memory, chunk_size: 100)
    |> ExAws.stream!()
  end

  defp account_status("ACTIVE"), do: :active
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
end
