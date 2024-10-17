defmodule BillionOak.Repo.Migrations.CreateCompanyRecords do
  use Ecto.Migration

  def change do
    create table(:company_records, primary_key: false) do
      add :id, :string, primary_key: true
      add :company_id, :string, null: false
      add :organization_id, :string, null: false
      add :company_account_id, :string, null: false
      add :dedupe_id, :string, null: false
      add :content, :map, null: false

      timestamps()
    end

    create index(:company_records, :company_id)
    create index(:company_records, :organization_id)
    create index(:company_records, :company_account_id)
    create unique_index(:company_records, :dedupe_id)
  end
end
