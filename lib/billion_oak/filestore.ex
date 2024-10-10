defmodule BillionOak.Filestore do
  def stream_s3_file(key) do
    result =
      "AWS_S3_BUCKET"
      |> System.fetch_env!()
      |> ExAws.S3.download_file(key, :memory)
      |> ExAws.stream!()

    {:ok, result}
  rescue
    e in [ExAws.Error] ->
      {:error, e}
  end
end
