defmodule BillionOak.Filestore.S3Client do
  alias BillionOak.Filestore.IClient
  @behaviour IClient

  @impl IClient
  def stream_object(key) do
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

  @impl IClient
  def list_objects(prefix, start_after \\ nil) do
    "AWS_S3_BUCKET"
    |> System.fetch_env!()
    |> ExAws.S3.list_objects_v2(prefix: prefix, max_keys: 1000, start_after: start_after)
    |> ExAws.request()
    |> case do
      {:ok, %{body: body}} -> {:ok, body.contents}
      other -> other
    end
  end

  @impl IClient
  def presigned_url(key) do
    bucket = System.fetch_env!("AWS_S3_BUCKET")

    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:post, bucket, key, expires_in: 86_400)
  end

  @impl IClient
  def presigned_post(key, conditions \\ []) do
    bucket = System.fetch_env!("AWS_S3_BUCKET")
    default_opts = [expires_in: 86_400]

    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_post(bucket, key, default_opts ++ [custom_conditions: conditions])
  end
end