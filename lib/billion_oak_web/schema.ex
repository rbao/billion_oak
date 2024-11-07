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

    @desc "Reserve a file location"
    field :reserve_file_location, type: :file_location do
      arg(:name, non_null(:string))
      arg(:content_type, :string)
      resolve(&Resolver.reserve_file_location/3)
    end

    @desc "Register a file in a given location"
    field :register_file, type: :file do
      arg(:location_id, non_null(:id))
      resolve(&Resolver.register_file/3)
    end

    @desc "Create an audio"
    field :create_audio, type: :audio do
      arg(:input, non_null(:create_audio_input))
      resolve(&Resolver.create_audio/3)
    end

    @desc "Update audios"
    field :update_audios, type: list_of(:audio) do
      arg(:input, non_null(:update_audios_input))
      resolve(&Resolver.update_audios/3)
    end

    @desc "Delete audios"
    field :delete_audios, type: :delete_audios_output do
      arg(:input, non_null(:delete_audios_input))
      resolve(&Resolver.delete_audios/3)
    end
  end

  input_object :create_audio_input do
    field :status, :string
    field :primary_file_id, non_null(:id)
    field :number, non_null(:string)
    field :title, non_null(:string)
    field :speaker_names, non_null(:string)
  end

  input_object :update_audios_input do
    field :id, non_null(list_of(non_null(:id)))
    field :status, :string
  end

  input_object :delete_audios_input do
    field :id, non_null(list_of(non_null(:id)))
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
