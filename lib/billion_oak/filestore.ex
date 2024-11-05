defmodule BillionOak.Filestore do
  @moduledoc """
  The Feilstore context.
  """
  use OK.Pipe
  import Ecto.Query, warn: false
  alias BillionOak.{Repo, Query, Request}
  alias BillionOak.Filestore.{Client, FileLocation}

  def list_objects(prefix, start_after \\ nil) do
    Client.list_objects(prefix, start_after)
  end

  def stream_object(key) do
    Client.stream_object(key)
  end

  @doc """
  Returns the list of locations.

  ## Examples

      iex> list_locations()
      {:ok, [%FileLocation{}, ...]}

  """
  def list_locations do
    {:ok, Repo.all(FileLocation)}
  end

  @doc """
  Gets a single location.

  ## Examples

      iex> get_location(123)
      {:ok, %FileLocation{}}

      iex> get_location(456)
      {:error, :not_found}

  """
  def get_location(id) do
    case Repo.get(FileLocation, id) do
      nil -> {:error, :not_found}
      location -> {:ok, location}
    end
  end

  @doc """
  Reserves a location for file upload.

  ## Examples

      iex> reserve_location(%{field: value})
      {:ok, %FileLocation{}}

      iex> reserve_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def reserve_location(attrs \\ %{}) do
    %FileLocation{}
    |> FileLocation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %FileLocation{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%FileLocation{} = location, attrs) do
    location
    |> FileLocation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %FileLocation{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%FileLocation{} = location) do
    Repo.delete(location)
  end

  alias BillionOak.Filestore.File

  @doc """
  Returns the list of files.

  ## Examples

      iex> list_files()
      {:ok, [%File{}, ...]}

  """
  def list_files(req \\ %Request{}) do
    result =
      File
      |> Query.to_query()
      |> Query.for_organization(req.organization_id)
      |> Query.filter(req.filter, req._filterable_keys_)
      |> Query.sort(req.sort, req._sortable_keys_)
      |> Query.paginate(req.pagination)
      |> Repo.all()
      |> File.put_url()

    {:ok, result}
  end

  @doc """
  Gets a single file.

  ## Examples

      iex> get_file("123")
      {:ok, %File{}}

      iex> get_file("456")
      {:error, :not_found}

  """
  def get_file(id) do
    case Repo.get(File, id) do
      nil -> {:error, :not_found}
      file -> {:ok, file}
    end
  end

  @doc """
  Registers a file.

  ## Examples

      iex> register_file(%{field: value})
      {:ok, %File{}}

      iex> register_file(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_file(attrs \\ %{}) do
    %File{}
    |> File.changeset(:register, attrs)
    |> Repo.insert()
    ~> File.put_url()
  end

  @doc """
  Updates a file.

  ## Examples

      iex> update_file(file, %{field: new_value})
      {:ok, %File{}}

      iex> update_file(file, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_file(%File{} = file, attrs) do
    file
    |> File.changeset(:update, attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a file.

  ## Examples

      iex> delete_file(file)
      {:ok, %File{}}

      iex> delete_file(file)
      {:error, %Ecto.Changeset{}}

  """
  def delete_file(%File{} = file) do
    Repo.delete(file)
  end

  def delete_files(req \\ %Request{}) do
    {count, _} =
      File
      |> Query.to_query()
      |> Query.for_organization(req.organization_id)
      |> Query.filter(req.filter, req._filterable_keys_)
      |> Repo.delete_all()

    {:ok, {count, nil}}
  end
end
