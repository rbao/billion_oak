defmodule BillionOak.Identity.User do
  use BillionOak.Schema, id_prefix: "usr"

  schema "users" do
    field :role, Ecto.Enum, values: [:guest, :member, :admin], default: :guest
    field :first_name, :string
    field :last_name, :string
    field :organization_id, :string
    field :company_account_id, :string
    field :wx_app_openid, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([
      :role,
      :organization_id,
    ])
  end
end
