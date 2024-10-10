defmodule BillionOak.Customer.Account do
  use BillionOak.Schema, id_prefix: "acct"
  alias BillionOak.Customer.{Company, Organization, Account}

  schema "customer_accounts" do
    field :is_root, :boolean, default: false
    field :status, Ecto.Enum, values: [:active, :inactive, :terminated], default: :active
    field :name, :string
    field :state, :string
    field :number, :string
    field :enroller_number, :string
    field :sponsor_number, :string
    field :country_code, :string
    field :phone1, :string
    field :phone2, :string
    field :city, :string
    field :enrolled_at, :utc_datetime

    timestamps(type: :utc_datetime)

    belongs_to :company, Company
    belongs_to :organization, Organization
    belongs_to :enroller, Account
    belongs_to :sponsor, Account
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([:number, :status, :name, :company_id, :organization_id])
  end
end
