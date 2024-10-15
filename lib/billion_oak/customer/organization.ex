defmodule BillionOak.Customer.Organization do
  use BillionOak.Schema, id_prefix: "org"
  alias BillionOak.Customer.Company

  schema "customer_organizations" do
    field :name, :string
    field :handle, :string
    field :root_account_rid, :string
    field :ingestion_cursor, :string

    timestamps()

    belongs_to :company, Company
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([:name, :handle, :company_id, :root_account_rid])
  end
end
