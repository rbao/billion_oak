defmodule BillionOak.Repo.Migrations.CreateCustomerCompanies do
  use Ecto.Migration

  def change do
    create table(:customer_companies, primary_key: false) do
      add :id, :string, primary_key: true
      add :alias, :string, null: false
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:customer_companies, [:alias])
  end
end
