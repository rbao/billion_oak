defmodule BillionOak.Customer.AccountRecord do
  use BillionOak.Schema, id_prefix: "acrec"
  alias BillionOak.Customer.{Company, Organization, Account}

  schema "customer_account_records" do
    field :dedupe_id, :string
    field :content, :map

    timestamps()

    belongs_to :company, Company
    belongs_to :organization, Organization
    belongs_to :account, Account
  end

  @doc false
  def changeset(account_record, attrs) do
    account_record
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([:dedupe_id, :content, :company_id, :organization_id, :account_id])
  end
end
