defmodule BillionOak.Ingestion.Attempt do
  use BillionOak.Schema, id_prefix: "inatp"
  alias BillionOak.External.{Company, Organization}

  schema "ingestion_attempts" do
    field :status, Ecto.Enum, values: [:running, :succeeded, :failed], default: :running
    field :format, :string
    field :s3_key, :string
    field :schema, :string
    field :sha256, :string
    field :size_bytes, :string

    timestamps()

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
      :format,
      :company_id,
      :organization_id
    ])
  end
end
