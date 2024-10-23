defmodule BillionOakWeb.Schema do
  use Absinthe.Schema
  import_types(BillionOakWeb.Schema.Types)

  alias BillionOakWeb.Resolver

  query do
    @desc "Get a company account excerpt"
    field :company_account_excerpt, :company_account_excerpt do
      arg(:rid, non_null(:string))
      resolve(&Resolver.get_company_account_excerpt/3)
    end
  end

  mutation do
    @desc "Create an invitation code"
    field :create_invitation_code, type: :invitation_code do
      arg(:rid, non_null(:string))
      resolve(&Resolver.create_invitation_code/3)
    end

    @desc "Sign up with an invitation code"
    field :sign_up, type: :user do
      arg(:company_account_rid, non_null(:string))
      arg(:invitation_code, non_null(:string))
      arg(:first_name, :string)
      arg(:last_name, non_null(:string))
      resolve(&Resolver.sign_up/3)
    end
  end
end
