defmodule BillionOak.Filestore do
  @moduledoc """
  The Feilstore context.
  """

  import Ecto.Query, warn: false
  alias BillionOak.Repo
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
end
