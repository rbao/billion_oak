defmodule BillionOak.Repo.Migrations.CreateCustomerAccountRecords do
  use Ecto.Migration

  def change do
    create table(:customer_account_records, primary_key: false) do
      add :id, :string, primary_key: true
      add :dedupe_id, :string, null: false
      add :content, :map

      timestamps(type: :utc_datetime)
    end
  end
end
