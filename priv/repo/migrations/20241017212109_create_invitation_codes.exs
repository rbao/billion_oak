defmodule BillionOak.Repo.Migrations.CreateInvitationCodes do
  use Ecto.Migration

  def change do
    create table(:invitation_codes, primary_key: false) do
      add :id, :string, primary_key: true
      add :status, :string, null: false
      add :organization_id, :string, null: false
      add :value, :string, null: false
      add :inviter_id, :string
      add :invitee_company_account_rid, :string, null: false
      add :invitee_role, :string, null: false
      add :expires_at, :utc_datetime, null: false
      add :payment_due_date, :date

      timestamps()
    end

    create unique_index(:invitation_codes, [:organization_id, :value])
    create index(:invitation_codes, :inviter_id)
  end
end
