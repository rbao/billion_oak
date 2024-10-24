defmodule BillionOak.Filestore.S3 do
  alias BillionOak.IFilestore
  @behaviour IFilestore

  @impl IFilestore
  def stream_file(key) do
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

  @impl IFilestore
  def list_files(prefix, start_after \\ nil) do
    "AWS_S3_BUCKET"
    |> System.fetch_env!()
    |> ExAws.S3.list_objects_v2(prefix: prefix, max_keys: 1000, start_after: start_after)
    |> ExAws.request()
    |> case do
      {:ok, %{body: body}} -> {:ok, body.contents}
      other -> other
    end
  end
end