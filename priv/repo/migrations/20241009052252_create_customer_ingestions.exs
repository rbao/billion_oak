defmodule BillionOak.Repo.Migrations.CreateCustomerIngestions do
  use Ecto.Migration

  def change do
    create table(:customer_ingestions, primary_key: false) do
      add :id, :string, primary_key: true
      add :company_id, :string, null: false
      add :organization_id, :string, null: false
      add :status, :string
      add :url, :string
      add :sha256, :string
      add :size_bytes, :string
      add :format, :string
      add :schema, :string

      timestamps(type: :utc_datetime)
    end

    create index(:customer_ingestions, :company_id)
    create index(:customer_ingestions, :organization_id)
  end
end
