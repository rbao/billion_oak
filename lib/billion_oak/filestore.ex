defmodule BillionOak.Filestore do
  def stream_s3_file(key) do
    "AWS_S3_BUCKET"
    |> System.fetch_env!()
    |> ExAws.S3.download_file(key, :memory)
    |> ExAws.stream!()
  end
end
