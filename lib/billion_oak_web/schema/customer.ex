defmodule BillionOakWeb.Schema.Customer do
  use Absinthe.Schema.Notation

  object :customer_company do
    field :id, :id
    field :name, :string
    field :handle, :string
  end

  object :customer_account_excerpt do
    field :id, :id
    field :rid, :string
    field :phone1, :string
    field :phone2, :string
  end
end
