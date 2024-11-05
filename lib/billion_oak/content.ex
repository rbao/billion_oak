defmodule BillionOak.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias BillionOak.{Repo, Request, Query, Validation, Filestore}

  alias BillionOak.Content.Audio

  @doc """
  Returns the list of audios.

  ## Examples

      iex> list_audios()
      [%Audio{}, ...]

  """
  def list_audios(req \\ %Request{}) do
    Audio
    |> Query.to_query()
    |> Query.for_organization(req.organization_id)
    |> Query.filter(req.filter, req._filterable_keys_)
    |> Query.sort(req.sort, req._sortable_keys_)
    |> Query.paginate(req.pagination)
    |> Repo.all()
  end

  def count_audios(req \\ %Request{}) do
    Audio
    |> Query.to_query()
    |> Query.for_organization(req.organization_id)
    |> Query.filter(req.filter, req._filterable_keys_)
    |> Repo.aggregate(:count)
  end

  @doc """
  Gets a single audio.

  ## Examples

      iex> get_audio!(123)
      {:ok, %Audio{}}

      iex> get_audio!(456)
      {:error, :not_found}

  """
  def get_audio(id) do
    case Repo.get(Audio, id) do
      nil -> {:error, :not_found}
      audio -> {:ok, audio}
    end
  end

  @doc """
  Creates a audio.

  ## Examples

      iex> create_audio(%{field: value})
      {:ok, %Audio{}}

      iex> create_audio(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_audio(attrs \\ %{}) do
    %Audio{}
    |> Audio.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a audio.

  ## Examples

      iex> update_audio(audio, %{field: new_value})
      {:ok, %Audio{}}

      iex> update_audio(audio, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_audio(%Audio{} = audio, attrs) do
    audio
    |> Audio.changeset(attrs)
    |> Repo.update()
  end

  def update_audios(req \\ %Request{}) do
    audios =
      Audio
      |> Query.to_query()
      |> Query.for_organization(req.organization_id)
      |> Query.filter(req.filter, req._filterable_keys_)
      |> Repo.all()

    changesets =
      Enum.map(audios, fn audio ->
        Audio.changeset(audio, req.data)
      end)

    invalid_changesets = Validation.invalid_changesets(changesets)

    case invalid_changesets do
      [] -> do_update_audios(changesets)
      invalid_changesets -> {:error, invalid_changesets}
    end
  end

  defp do_update_audios(changesets) do
    multi =
      Enum.reduce(changesets, Multi.new(), fn changeset, multi ->
        Multi.update(multi, changeset.data.id, changeset)
      end)

    case Repo.transaction(multi) do
      {:ok, results} ->
        updated_audios = Enum.map(results, fn {_, audio} -> audio end)
        {:ok, updated_audios}

      {:error, _, changeset, _} ->
        {:error, [changeset]}
    end
  end

  @doc """
  Deletes a audio.

  ## Examples

      iex> delete_audio(audio)
      {:ok, %Audio{}}

      iex> delete_audio(audio)
      {:error, %Ecto.Changeset{}}

  """
  def delete_audio(%Audio{} = audio) do
    Repo.delete(audio)
  end

  def delete_audios(req \\ %Request{}) do
    audio_query =
      Audio
      |> Query.to_query()
      |> Query.for_organization(req.organization_id)
      |> Query.filter(req.filter, req._filterable_keys_)

    audios = Repo.all(audio_query)

    file_ids =
      audios
      |> Enum.map(& &1.primary_file_id)
      |> Enum.uniq()

    multi =
      Multi.new()
      |> Multi.delete_all(:delete_audios, audio_query)
      |> Multi.run(:delete_files, fn _repo, _changes ->
        {:ok, _} =
          Filestore.delete_files(%Request{
            organization_id: req.organization_id,
            filter: %{id: file_ids}
          })
      end)

    case Repo.transaction(multi) do
      {:ok, %{delete_audios: {count, _}}} ->
        {:ok, {count, audios}}

      {:error, _failed_operation, failed_value, _changes} ->
        {:error, failed_value}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking audio changes.

  ## Examples

      iex> change_audio(audio)
      %Ecto.Changeset{data: %Audio{}}

  """
  def change_audio(%Audio{} = audio, attrs \\ %{}) do
    Audio.changeset(audio, attrs)
  end
end
