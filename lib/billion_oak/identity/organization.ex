defmodule BillionOak.Identity.Organization do
  use BillionOak.Schema, id_prefix: "org"
  alias BillionOak.External.Company

  schema "organizations" do
    field :name, :string
    field :handle, :string
    field :root_company_account_rid, :string
    field :ingestion_cursor, :string

    timestamps()

    belongs_to :company, Company
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([:name, :handle, :company_id, :root_company_account_rid])
  end
end
