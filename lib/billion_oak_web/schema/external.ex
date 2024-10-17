defmodule BillionOakWeb.Schema.External do
  use Absinthe.Schema.Notation

  object :company do
    field :id, :id
    field :name, :string
    field :handle, :string
  end

  object :company_account_excerpt do
    field :id, :id
    field :rid, :string
    field :phone1, :string
    field :phone2, :string
  end
end
