defmodule BillionOak.Repo.Migrations.CreateCustomerAccounts do
  use Ecto.Migration

  def change do
    create table(:customer_accounts, primary_key: false) do
      add :id, :string, primary_key: true
      add :is_root, :boolean, null: false
      add :company_id, :string, null: false
      add :organization_id, :string, null: false
      add :number, :string, null: false
      add :enroller_number, :string
      add :enroller_id, :string
      add :sponsor_number, :string
      add :sponsor_id, :string
      add :status, :string, null: false
      add :country_code, :string
      add :name, :string, null: false
      add :phone1, :string
      add :phone2, :string
      add :city, :string
      add :state, :string
      add :enrolled_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:customer_accounts, :company_id)
    create index(:customer_accounts, :organization_id)
  end
end
