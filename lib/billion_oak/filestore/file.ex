defmodule BillionOak.Filestore.File do
  use BillionOak.Schema, id_prefix: "file"
  import Ecto.Changeset
  alias BillionOak.Identity.{Organization, User}
  alias BillionOak.Filestore.FileLocation
  alias BillionOak.Repo

  schema "files" do
    field :name, :string
    field :status, Ecto.Enum, values: [:active, :deleted], default: :active
    field :content_type, :string
    field :size_bytes, :integer

    field :url, :string, virtual: true
    field :location_id, :string, virtual: true
    field :location, :map, virtual: true

    timestamps()

    belongs_to :organization, Organization
    belongs_to :owner, User
  end

  @doc false
  def changeset(file, :register, attrs) do
    file
    |> cast(attrs, [:name, :organization_id, :owner_id, :status, :location_id])
    |> validate_required([:name, :organization_id, :owner_id, :status, :location_id])
    |> put_location()
    |> validate_location()
    |> from_location()
  end

  def changeset(file, :update, attrs) do
    file
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end

  defp put_location(%{valid?: false} = cs), do: cs

  defp put_location(cs) do
    location_id = get_field(cs, :location_id)
    location = Repo.get(FileLocation, location_id)
    change(cs, location: location)
  end

  defp validate_location(%{valid?: false} = cs), do: cs

  defp validate_location(cs) do
    if get_field(cs, :location) do
      cs
    else
      add_error(cs, :location_id, "does not exist", validation: :must_exist)
    end
  end

  defp from_location(%{valid?: false} = cs), do: cs

  defp from_location(cs) do
    location = get_field(cs, :location)

    case FileLocation.metadata(location) do
      {:ok, metadata} ->
        metadata
        |> Enum.reduce(cs, fn {k, v}, acc ->
          put_change(acc, k, v)
        end)
        |> change(id: location.id)
        |> change(name: location.name)
        |> change(organization_id: location.organization_id)
        |> change(owner_id: location.owner_id)

      {:error, :not_found} ->
        add_error(cs, :location_id, "does not have content", validation: :must_have_content)

      {:error, :access_denied} ->
        add_error(cs, :location_id, "access denied", validation: :must_be_accessible)
    end
  end
end
