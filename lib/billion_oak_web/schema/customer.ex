defmodule BillionOakWeb.Schema.Customer do
  use Absinthe.Schema.Notation

  object :customer_company do
    field :id, :id
    field :name, :string
    field :handle, :string
  end
end
