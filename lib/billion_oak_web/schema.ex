defmodule BillionOakWeb.Schema do
  use Absinthe.Schema
  import_types(BillionOakWeb.Schema.Customer)

  alias BillionOakWeb.Resolvers

  query do
    @desc "List all customer companies"
    field :customer_companies, list_of(:customer_company) do
      resolve(&Resolvers.Customer.list_companies/3)
    end
  end
end
