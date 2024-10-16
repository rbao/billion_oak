defmodule BillionOak.Identity.Client do
  use BillionOak.Schema, id_prefix: "clt"
  import Ecto.Changeset

  schema "clients" do
    field :name, :string
    # Rename to refresh_token
    field :refresh_token, :string
    field :organization_id, :string

    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> changeset()
    |> cast(attrs, [:name, :organization_id])
    |> put_refresh_token()
    |> validate_required([:name, :organization_id, :refresh_token])
  end

  defp put_refresh_token(%{data: %{refresh_token: nil}} = changeset) do
    # PRT means publishable refresh token
    change(changeset, refresh_token: "prt_" <> XCUID.generate())
  end

  defp put_refresh_token(changeset), do: changeset
end
