defmodule BillionOak.Customer.Organization do
  use BillionOak.Schema, id_prefix: "org"

  schema "customer_organizations" do
    field :name, :string
    field :org_structure_last_ingested_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> changeset()
    |> cast(attrs, [:name, :org_structure_last_ingested_at])
    |> validate_required([:name, :org_structure_last_ingested_at])
  end
end
