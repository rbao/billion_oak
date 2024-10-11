defmodule BillionOak.Repo.Migrations.CreateCustomerOrganizations do
  use Ecto.Migration

  def change do
    create table(:customer_organizations, primary_key: false) do
      add :id, :string, primary_key: true
      add :company_id, :string, null: false
      add :name, :string, null: false
      add :alias, :string, null: false
      add :root_account_number, :string, null: false
      add :org_structure_last_ingested_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:customer_organizations, :company_id)
  end
end
