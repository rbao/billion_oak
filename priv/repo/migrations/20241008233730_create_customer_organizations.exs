defmodule BillionOak.Repo.Migrations.CreateCustomerOrganizations do
  use Ecto.Migration

  def change do
    create table(:customer_organizations, primary_key: false) do
      add :id, :string, primary_key: true
      add :company_id, :string, null: false
      add :name, :string, null: false
      add :handle, :string, null: false
      add :root_account_rid, :string, null: false
      add :ingestion_cursor, :string

      timestamps()
    end

    create index(:customer_organizations, :company_id)
    create unique_index(:customer_organizations, [:company_id, :handle])
  end
end
