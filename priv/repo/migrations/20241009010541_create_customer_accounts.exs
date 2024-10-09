defmodule BillionOak.Repo.Migrations.CreateCustomerAccounts do
  use Ecto.Migration

  def change do
    create table(:customer_accounts, primary_key: false) do
      add :id, :string, primary_key: true
      add :number, :string
      add :status, :string
      add :country_code, :string
      add :name, :string
      add :phone1, :string
      add :phone2, :string
      add :city, :string
      add :state, :string
      add :enrolled_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
