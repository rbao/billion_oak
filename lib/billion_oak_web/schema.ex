defmodule BillionOakWeb.Schema do
  use Absinthe.Schema
  import_types(BillionOakWeb.Schema.External)

  alias BillionOakWeb.Resolvers

  query do
    @desc "List all companies"
    field :companies, list_of(:company) do
      resolve(&Resolvers.External.list_companies/3)
    end

    @desc "Get a company account excerpt"
    field :company_account_excerpt, :company_account_excerpt do
      arg(:rid, non_null(:string))
      resolve(&Resolvers.External.get_company_account_excerpt/3)
    end
  end
end
