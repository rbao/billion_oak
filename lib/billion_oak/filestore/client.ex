defmodule BillionOak.Filestore.IClient do
  @type object :: %{key: binary()}

  @callback stream_object(binary()) :: {:ok, Enumerable.t()} | {:error, any()}
  @callback list_objects(binary(), binary() | nil) :: {:ok, list(object())} | {:error, any()}
  @callback presigned_url(binary()) :: binary()
  @callback presigned_post(binary(), list(map())) :: map()
end

defmodule BillionOak.Filestore.Client do
  alias BillionOak.Filestore.S3Client
  @store Application.compile_env(:billion_oak, __MODULE__, S3Client)

  defdelegate stream_object(key), to: @store
  defdelegate list_objects(prefix, start_after), to: @store
  defdelegate presigned_url(key), to: @store
  defdelegate presigned_post(key, conditions), to: @store
end
