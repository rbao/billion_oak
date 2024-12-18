defmodule BillionOak.Repo.Migrations.CreateCompanyCompanyAccounts do
  use Ecto.Migration

  def change do
    create table(:company_accounts, primary_key: false) do
      add :id, :string, primary_key: true
      add :is_root, :boolean, null: false
      add :company_id, :string, null: false
      add :organization_id, :string, null: false
      add :rid, :string, null: false
      add :enroller_rid, :string
      add :sponsor_rid, :string
      add :status, :string, null: false
      add :country_code, :string
      add :name, :string, null: false
      add :phone1, :string
      add :phone2, :string
      add :city, :string
      add :state, :string
      add :enrolled_at, :utc_datetime
      add :custom_data, :map

      timestamps()
    end

    create index(:company_accounts, :company_id)
    create index(:company_accounts, :organization_id)
    create unique_index(:company_accounts, [:company_id, :organization_id, :rid])
  end
end
