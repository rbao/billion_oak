defmodule BillionOak.Repo.Migrations.CreateCustomerOrganizations do
  use Ecto.Migration

  def change do
    create table(:customer_organizations, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
      add :org_structure_last_ingested_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
