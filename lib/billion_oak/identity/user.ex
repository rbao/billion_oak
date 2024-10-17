defmodule BillionOak.Identity.User do
  use BillionOak.Schema, id_prefix: "usr"

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :organization_id, :string
    field :company_id, :string
    field :company_account_id, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> changeset()
    |> cast(attrs, [:first_name, :last_name, :organization_id, :company_id, :company_account_id])
    |> validate_required([:first_name, :last_name, :organization_id, :company_id, :company_account_id])
  end
end
