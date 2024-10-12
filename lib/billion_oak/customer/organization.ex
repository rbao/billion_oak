defmodule BillionOak.Customer.Organization do
  use BillionOak.Schema, id_prefix: "org"
  alias BillionOak.Customer.Company

  schema "customer_organizations" do
    field :name, :string
    field :alias, :string
    field :root_account_number, :string
    field :org_structure_last_ingested_at, :utc_datetime

    timestamps()

    belongs_to :company, Company
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([:name, :alias, :company_id, :root_account_number])
  end
end
