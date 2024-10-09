defmodule BillionOak.Customer.Account do
  use BillionOak.Schema, id_prefix: "acct"

  schema "customer_accounts" do
    field :name, :string
    field :status, :string
    field :state, :string
    field :number, :string
    field :country_code, :string
    field :phone1, :string
    field :phone2, :string
    field :city, :string
    field :enrolled_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> changeset()
    |> cast(attrs, [:number, :status, :country_code, :name, :phone1, :phone2, :city, :state, :enrolled_at])
    |> validate_required([:number, :status, :country_code, :name, :phone1, :phone2, :city, :state, :enrolled_at])
  end
end
