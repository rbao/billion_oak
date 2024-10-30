defmodule BillionOak.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias BillionOak.Repo

  alias BillionOak.Content.Audio

  @doc """
  Returns the list of audios.

  ## Examples

      iex> list_audios()
      {:ok, [%Audio{}, ...]}

  """
  def list_audios do
    {:ok, Repo.all(Audio)}
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
