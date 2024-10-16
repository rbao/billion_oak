defmodule BillionOak.Identity.Client do
  use BillionOak.Schema, id_prefix: "clt"
  import Ecto.Changeset

  schema "clients" do
    field :name, :string
    field :secret, :string
    field :organization_id, :string

    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> changeset()
    |> cast(attrs, [:name, :organization_id])
    |> put_secret()
    |> validate_required([:name, :organization_id, :secret])
  end

  defp put_secret(%{data: %{secret: nil}} = changeset) do
    change(changeset, secret: generate_secret())
  end

  defp put_secret(changeset), do: changeset

  defp generate_secret do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)
  end
end
