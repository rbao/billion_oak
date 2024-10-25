defmodule BillionOakWeb.Schema do
  use Absinthe.Schema
  alias BillionOakWeb.Schema.{DataSource, Resolver}
  import_types(BillionOakWeb.Schema.Types)

  query do
    @desc "Get a company account excerpt"
    field :company_account_excerpt, :company_account_excerpt do
      arg(:rid, non_null(:string))
      resolve(&Resolver.get_company_account_excerpt/3)
    end

    @desc "Get the current user"
    field :current_user, :user do
      resolve(&Resolver.get_current_user/3)
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

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(DataSource, DataSource.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
