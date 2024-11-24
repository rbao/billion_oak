defmodule BillionOakWeb.Schema.Types do
  use Absinthe.Schema.Notation
  alias BillionOakWeb.Schema.Resolver
  import_types(Absinthe.Type.Custom)

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

  object :invitation_code do
    field :value, :string
    field :inviter_id, :id
    field :invitee_company_account_rid, :string
    field :expires_at, :datetime
  end

  object :company_account do
    field :id, :id
    field :rid, :string
    field :name, :string
    field :status, :string
    field :country_code, :string
    field :enrolled_at, :datetime
  end

  object :user do
    field :id, :id
    field :share_id, :id
    field :first_name, :string
    field :last_name, :string
    field :role, :string
    field :company_account_id, :id
    field :organization_id, :id
    field :avatar_file_id, :id

    field :company_account, :company_account do
      resolve(&Resolver.load_company_accounts/3)
    end

    field :avatar_file, :file do
      resolve(&Resolver.load_files/3)
    end
  end

  object :sharer do
    field :first_name, :string
    field :last_name, :string

    field :avatar_file, :file do
      resolve(&Resolver.load_files/3)
    end
  end

  object :file_form_field do
    field :name, :string
    field :value, :string
  end

  object :file_location do
    field :id, :id
    field :name, :string
    field :form_url, :string
    field :form_fields, list_of(:file_form_field)
  end

  object :file do
    field :id, :id
    field :name, :string
    field :status, :string
    field :content_type, :string
    field :size_bytes, :integer
    field :url, :string
  end

  object :audio do
    field :id, :id
    field :status, :string
    field :number, :string
    field :title, :string
    field :speaker_names, :string
    field :duration_seconds, :integer
    field :inserted_at, :datetime
    field :updated_at, :datetime

    field :primary_file, :file do
      resolve(&Resolver.load_files/3)
    end
  end

  input_object :sort_input do
    field :field, non_null(:string)
    field :ordering, non_null(:string)
  end

  input_object :pagination_input do
    field :number, :integer
    field :size, :integer
  end

  object :pagination do
    field :number, :integer
    field :size, :integer
  end

  object :metadata_for_list do
    field :total_count, :integer
    field :pagination, :pagination
  end

  object :metadata_for_delete do
    field :count, :integer
  end

  object :get_current_user_output do
    field :data, :user
  end

  input_object :get_sharer_input do
    field :id, :id
  end

  object :get_sharer_output do
    field :data, :sharer
  end

  object :sign_up_output do
    field :data, :user
  end

  input_object :update_current_user_input do
    field :first_name, :string
    field :last_name, :string
    field :avatar_file_id, :id
  end

  object :update_current_user_output do
    field :data, :user
  end

  input_object :create_invitation_code_input do
    field :invitee_company_account_rid, non_null(:string)
    field :payment_due_date, :date
  end

  object :create_invitation_code_output do
    field :data, :invitation_code
  end

  object :reserve_file_location_output do
    field :data, :file_location
  end

  object :register_file_output do
    field :data, :file
  end

  input_object :audio_filter_input do
    field :status, list_of(:string)
  end

  input_object :list_audios_input do
    field :filter, :audio_filter_input
    field :search, :string
    field :sort, list_of(non_null(:sort_input))
    field :pagination, :pagination_input
  end

  object :list_audios_output do
    field :data, list_of(:audio)
    field :meta, :metadata_for_list
  end

  input_object :create_audio_input do
    field :status, :string
    field :primary_file_id, non_null(:id)
    field :number, non_null(:string)
    field :title, non_null(:string)
    field :speaker_names, non_null(:string)
  end

  object :create_audio_output do
    field :data, :audio
  end

  input_object :get_audio_input do
    field :id, non_null(:id)
  end

  object :get_audio_output do
    field :data, :audio
  end

  input_object :update_audio_input do
    field :id, non_null(:id)
    field :status, :string
    field :primary_file_id, :id
    field :number, :string
    field :title, :string
    field :speaker_names, :string
  end

  object :update_audio_output do
    field :data, :audio
  end

  input_object :update_audios_input do
    field :id, non_null(list_of(non_null(:id)))
    field :status, :string
  end

  object :update_audios_output do
    field :data, list_of(:audio)
  end

  input_object :delete_audios_input do
    field :id, non_null(list_of(non_null(:id)))
  end

  object :delete_audios_output do
    field :data, list_of(:audio)
    field :meta, :metadata_for_delete
  end
end
