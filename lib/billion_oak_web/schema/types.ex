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
    field :first_name, :string
    field :last_name, :string
    field :role, :string
    field :company_account_id, :id
    field :organization_id, :id

    field :company_account, :company_account do
      resolve(&Resolver.load_company_accounts/3)
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

  input_object :audio_filter_input do
    field :status, list_of(:string)
  end

  input_object :list_audios_input do
    field :filter, :audio_filter_input
    field :sort, list_of(non_null(:sort_input))
    field :pagination, :pagination_input
  end

  object :list_audios_output do
    field :data, list_of(:audio)
    field :meta, :metadata_for_list
  end

  object :delete_audios_output do
    field :data, list_of(:audio)
    field :meta, :metadata_for_delete
  end
end
