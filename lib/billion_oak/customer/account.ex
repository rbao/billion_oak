defmodule BillionOak.Customer.Account do
  use BillionOak.Schema, id_prefix: "acct"
  alias BillionOak.Customer.{Company, Organization}

  schema "customer_accounts" do
    field :name, :string
    field :status, Ecto.Enum, values: [:active, :inactive, :terminated]
    field :state, :string
    field :number, :string
    field :country_code, :string
    field :phone1, :string
    field :phone2, :string
    field :city, :string
    field :enrolled_at, :utc_datetime

    timestamps(type: :utc_datetime)

    belongs_to :company, Company
    belongs_to :organization, Organization
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([:number, :status, :name, :company_id, :organization_id])
  end
end
