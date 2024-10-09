defmodule BillionOak.Customer.Company do
  use BillionOak.Schema, id_prefix: "cmpy"

  schema "customer_companies" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([:name])
  end
end
