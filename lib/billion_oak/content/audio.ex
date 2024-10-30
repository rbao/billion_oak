defmodule BillionOak.Content.Audio do
  use BillionOak.Schema, id_prefix: "audio"
  import Ecto.Changeset
  alias BillionOak.Identity.Organization
  alias BillionOak.Filestore.File
  alias BillionOak.Repo

  schema "audios" do
    field :title, :string
    field :status, Ecto.Enum, values: [:draft, :published], default: :draft
    field :number, :string
    field :duration_seconds, :integer
    field :speaker_names, :string

    timestamps()

    belongs_to :organization, Organization
    belongs_to :primary_file, File
    belongs_to :cover_image_file, File
  end

  @doc false
  def changeset(audio, attrs) do
    audio
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([
      :number,
      :status,
      :title,
      :speaker_names,
      :duration_seconds,
      :primary_file_id,
      :organization_id
    ])
    |> put_primary_file()
    |> validate_primary_file()
    |> put_cover_image_file()
    |> validate_cover_image_file()
  end

  defp put_primary_file(%{valid?: true, changes: %{primary_file_id: primary_file_id}} = cs) do
    organization_id = get_field(cs, :organization_id)
    file = Repo.get_by(File, id: primary_file_id, organization_id: organization_id)
    change(cs, primary_file: file)
  end

  defp put_primary_file(cs), do: cs

  defp validate_primary_file(%{valid?: true, changes: %{primary_file_id: _}} = cs) do
    if get_field(cs, :primary_file) do
      cs
    else
      add_error(cs, :primary_file_id, "does not exist", validation: :must_exist)
    end
  end

  defp validate_primary_file(cs), do: cs

  defp put_cover_image_file(
         %{valid?: true, changes: %{cover_image_file_id: cover_image_file_id}} = cs
       ) do
    organization_id = get_field(cs, :organization_id)
    file = Repo.get_by(File, id: cover_image_file_id, organization_id: organization_id)
    change(cs, cover_image_file: file)
  end

  defp put_cover_image_file(cs), do: cs

  defp validate_cover_image_file(%{valid?: true, changes: %{cover_image_file_id: _}} = cs) do
    if get_field(cs, :cover_image_file) do
      cs
    else
      add_error(cs, :cover_image_file_id, "does not exist", validation: :must_exist)
    end
  end

  defp validate_cover_image_file(cs), do: cs
end
