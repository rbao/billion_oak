defmodule BillionOak.Customer.AccountRecord do
  use BillionOak.Schema, id_prefix: "acrec"

  schema "customer_account_records" do
    field :dedupe_id, :string
    field :content, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account_record, attrs) do
    account_record
    |> changeset()
    |> cast(attrs, [:dedupe_id, :content])
    |> validate_required([:dedupe_id])
  end
end
