defmodule BillionOak.Filestore do
  @moduledoc """
  The Feilstore context.
  """
  use OK.Pipe
  import Ecto.Query, warn: false
  alias BillionOak.{Repo, Query}
  alias BillionOak.Filestore.{Client, FileLocation, File}

  def list_objects(prefix, start_after \\ nil) do
    Client.list_objects(prefix, start_after)
  end

  def stream_object(key) do
    Client.stream_object(key)
  end

  def list_locations(_ \\ nil) do
    {:ok, Repo.all(FileLocation)}
  end

  def get_location(id) do
    case Repo.get(FileLocation, id) do
      nil -> {:error, :not_found}
      location -> {:ok, location}
    end
  end

  def reserve_location(%{data: data}), do: reserve_location(data)

  def reserve_location(data) do
    %FileLocation{}
    |> FileLocation.changeset(data)
    |> Repo.insert()
  end

  def update_location(%FileLocation{} = location, attrs) do
    location
    |> FileLocation.changeset(attrs)
    |> Repo.update()
  end

  def delete_location(%FileLocation{} = location) do
    Repo.delete(location)
  end

  def list_files(req \\ %{}) do
    result =
      File
      |> Query.to_query()
      |> Query.filter(req[:filter], req[:_filterable_keys_])
      |> Query.sort(req[:sort], req[:_sortable_keys_])
      |> Query.paginate(req[:pagination])
      |> Repo.all()
      |> File.put_url()

    {:ok, result}
  end

  def get_file(id) do
    case Repo.get(File, id) do
      nil -> {:error, :not_found}
      file -> {:ok, file}
    end
  end

  # TODO: delete the file location
  def register_file(%{data: data}), do: register_file(data)

  def register_file(data) do
    %File{}
    |> File.changeset(:register, data)
    |> Repo.insert()
    ~> File.put_url()
  end

  def update_file(%File{} = file, data) do
    file
    |> File.changeset(:update, data)
    |> Repo.update()
  end

  def delete_file(%File{} = file) do
    Repo.delete(file)
  end

  def delete_files(req \\ %{}) do
    {count, _} =
      File
      |> Query.to_query()
      |> Query.filter(req[:filter], req[:_filterable_keys_])
      |> Repo.delete_all()

    {:ok, {count, nil}}
  end
end
