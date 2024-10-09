defmodule BillionOak.Repo.Migrations.CreateCustomerCompanies do
  use Ecto.Migration

  def change do
    create table(:customer_companies, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
