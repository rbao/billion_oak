defmodule BillionOak.Identity.Client do
  use BillionOak.Schema, id_prefix: "clt"

  schema "clients" do
    field :name, :string
    field :secret, :string
    field :organization_id, :string
    field :publishable_key, :string, virtual: true
    field :wx_app_id, :string
    field :wx_app_secret, :string

    timestamps()
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> changeset()
    |> cast(attrs, [:name, :organization_id, :wx_app_id, :wx_app_secret])
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

  def put_publishable_key(clients) when is_list(clients) do
    Enum.map(clients, &put_publishable_key/1)
  end

  def put_publishable_key(%__MODULE__{id: id, secret: secret} = client) do
    publishable_key = Base.encode64("#{id}:#{secret}")
    %{client | publishable_key: publishable_key}
  end

  def put_publishable_key(client), do: client
end
