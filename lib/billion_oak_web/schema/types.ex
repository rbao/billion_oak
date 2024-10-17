defmodule BillionOakWeb.Schema.Types do
  use Absinthe.Schema.Notation
  import_types Absinthe.Type.Custom

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
end
