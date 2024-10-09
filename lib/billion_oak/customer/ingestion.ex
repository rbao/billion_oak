defmodule BillionOak.Customer.Ingestion do
  use BillionOak.Schema, id_prefix: "ing"

  schema "customer_ingestions" do
    field :status, :string
    field :format, :string
    field :url, :string
    field :schema, :string
    field :sha256, :string
    field :size_bytes, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ingestion, attrs) do
    ingestion
    |> changeset()
    |> cast(attrs, [:status, :url, :sha256, :size_bytes, :format, :schema])
    |> validate_required([:status, :url, :sha256, :size_bytes, :format, :schema])
  end
end
