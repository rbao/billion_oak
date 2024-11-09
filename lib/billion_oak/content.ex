defmodule BillionOak.Content do
  @moduledoc """
  The Content context.
  """
  use OK.Pipe
  import Ecto.Query, warn: false
  alias Ecto.{Multi, Changeset}
  alias BillionOak.{Repo, Query, Validation, Filestore}

  alias BillionOak.Content.Audio

  def list_audios(req \\ %{}) do
    Audio
    |> Query.to_query()
    |> Query.filter(req[:filter], req[:_filterable_keys_])
    |> Query.sort(req[:sort], req[:_sortable_keys_])
    |> Query.paginate(req[:pagination])
    |> Query.search(req[:search], [:title, :number, :speaker_names])
    |> Repo.all()
  end

  def count_audios(req \\ %{}) do
    Audio
    |> Query.to_query()
    |> Query.filter(req[:filter], req[:_filterable_keys_])
    |> Repo.aggregate(:count)
  end

  def get_audio(req \\ %{}) do
    case Repo.get_by(Audio, req[:identifier]) do
      nil -> {:error, :not_found}
      audio -> {:ok, audio}
    end
  end

  def create_audio(%{data: data}), do: create_audio(data)

  def create_audio(data) do
    %Audio{}
    |> Audio.changeset(data)
    |> Repo.insert()
  end

  def update_audio(%{data: data} = req) do
    get_audio(req)
    ~>> update_audio(data)
  end

  def update_audio(%Audio{} = audio, data) do
    changeset = Audio.changeset(audio, data)

    multi = Multi.update(Multi.new(), :audio, changeset)

    multi =
      if Changeset.changed?(changeset, :primary_file_id) do
        Multi.run(multi, :delete_file, fn _, _ ->
          Filestore.delete_files(%{
            filter: %{id: audio.primary_file_id},
            _filterable_keys_: [:id]
          })
        end)
      else
        multi
      end

    case Repo.transaction(multi) do
      {:ok, %{audio: audio}} -> {:ok, audio}
      {:error, _op, value, _changes} -> {:error, value}
    end
  end

  def update_audios(req \\ %{}) do
    audios =
      Audio
      |> Query.to_query()
      |> Query.filter(req[:filter], req[:_filterable_keys_])
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

  def delete_audio(%Audio{} = audio) do
    Repo.delete(audio)
  end

  def delete_audios(req \\ %{}) do
    audio_query =
      Audio
      |> Query.to_query()
      |> Query.filter(req[:filter], req[:_filterable_keys_])

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
          Filestore.delete_files(%{
            filter: %{id: file_ids},
            _filterable_keys_: [:id]
          })
      end)

    case Repo.transaction(multi) do
      {:ok, %{delete_audios: {count, _}}} ->
        {:ok, {count, audios}}

      {:error, _failed_operation, failed_value, _changes} ->
        {:error, failed_value}
    end
  end
end
