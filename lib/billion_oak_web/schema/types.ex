defmodule BillionOakWeb.Schema.Types do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers
  alias BillionOakWeb.Schema.DataSource
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
      resolve(dataloader(DataSource, use_parent: true))
    end
  end
end
