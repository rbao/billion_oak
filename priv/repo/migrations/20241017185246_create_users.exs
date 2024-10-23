defmodule BillionOak.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :string, primary_key: true
      add :role, :string, null: false
      add :first_name, :string
      add :last_name, :string
      add :organization_id, :string, null: false
      add :company_account_id, :string
      add :wx_app_openid, :string
      add :inviter_id, :string

      timestamps()
    end

    create index(:users, :organization_id)
    create index(:users, :company_account_id)
    create unique_index(:users, [:organization_id, :wx_app_openid])
  end
end
