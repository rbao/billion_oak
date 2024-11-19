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
    field :get_current_user, :get_current_user_output do
      resolve(&Resolver.get_current_user/3)
    end

    @desc "List audios"
    field :list_audios, :list_audios_output do
      arg(:input, :list_audios_input)
      resolve(&Resolver.list_audios/3)
    end

    @desc "Get an audio"
    field :get_audio, :get_audio_output do
      arg(:input, non_null(:get_audio_input))
      resolve(&Resolver.get_audio/3)
    end
  end

  mutation do
    @desc "Sign up with an invitation code"
    field :sign_up, type: :sign_up_output do
      arg(:company_account_rid, non_null(:string))
      arg(:invitation_code, non_null(:string))
      arg(:first_name, :string)
      arg(:last_name, non_null(:string))
      resolve(&Resolver.sign_up/3)
    end

    @desc "Update the current user"
    field :update_current_user, type: :update_current_user_output do
      arg(:input, non_null(:update_current_user_input))
      resolve(&Resolver.update_current_user/3)
    end

    @desc "Create an invitation code"
    field :create_invitation_code, type: :create_invitation_code_output do
      arg(:rid, non_null(:string))
      resolve(&Resolver.create_invitation_code/3)
    end

    @desc "Reserve a file location"
    field :reserve_file_location, type: :reserve_file_location_output do
      arg(:name, non_null(:string))
      arg(:content_type, :string)
      resolve(&Resolver.reserve_file_location/3)
    end

    @desc "Register a file in a given location"
    field :register_file, type: :register_file_output do
      arg(:location_id, non_null(:id))
      resolve(&Resolver.register_file/3)
    end

    @desc "Create an audio"
    field :create_audio, type: :create_audio_output do
      arg(:input, non_null(:create_audio_input))
      resolve(&Resolver.create_audio/3)
    end

    @desc "Update an audio"
    field :update_audio, type: :update_audio_output do
      arg(:input, non_null(:update_audio_input))
      resolve(&Resolver.update_audio/3)
    end

    @desc "Update audios"
    field :update_audios, type: :update_audios_output do
      arg(:input, non_null(:update_audios_input))
      resolve(&Resolver.update_audios/3)
    end

    @desc "Delete audios"
    field :delete_audios, type: :delete_audios_output do
      arg(:input, non_null(:delete_audios_input))
      resolve(&Resolver.delete_audios/3)
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
