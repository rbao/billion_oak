defmodule BillionOak.Customer.Ingestion do
  use BillionOak.Schema, id_prefix: "ing"
  alias BillionOak.Customer.{Company, Organization}

  schema "customer_ingestions" do
    field :status, Ecto.Enum, values: [:running, :succeeded, :failed], default: :running
    field :format, :string
    field :s3_key, :string
    field :schema, :string
    field :sha256, :string
    field :size_bytes, :string

    timestamps(type: :utc_datetime)

    belongs_to :company, Company
    belongs_to :organization, Organization
  end

  @doc false
  def changeset(ingestion, attrs) do
    ingestion
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([
      :status,
      :s3_key,
      :sha256,
      :size_bytes,
      :format,
      :schema,
      :company_id,
      :organization_id
    ])
  end
end
