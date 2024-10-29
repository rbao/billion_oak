defmodule BillionOak.Filestore do
  @moduledoc """
  The Feilstore context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias BillionOak.Repo

  alias BillionOak.Filestore.Client

  def list_objects(prefix, start_after \\ nil) do
    Client.list_objects(prefix, start_after)
  end

  def stream_object(key) do
    Client.stream_object(key)
  end
end
