defmodule BillionOak.IFilestore do

  @type file_object :: %{key: binary()}

  @callback stream_file(binary()) :: {:ok, Enumerable.t()} | {:error, any()}
  @callback list_files(binary(), binary() | nil) :: {:ok, list(file_object())} | {:error, any()}
end

defmodule BillionOak.Filestore do
  alias BillionOak.Filestore.S3
  @store Application.compile_env(:billion_oak, __MODULE__, S3)

  defdelegate stream_file(key), to: @store
  defdelegate list_files(prefix, start_after), to: @store
end
