defmodule BillionOak.Repo.Migrations.CreateCustomerAccountRecords do
  use Ecto.Migration

  def change do
    create table(:customer_account_records, primary_key: false) do
      add :id, :string, primary_key: true
      add :company_id, :string, null: false
      add :organization_id, :string, null: false
      add :account_id, :string, null: false
      add :dedupe_id, :string, null: false
      add :content, :map, null: false

      timestamps()
    end

    create index(:customer_account_records, :company_id)
    create index(:customer_account_records, :organization_id)
    create index(:customer_account_records, :account_id)
    create unique_index(:customer_account_records, :dedupe_id)
  end
end
