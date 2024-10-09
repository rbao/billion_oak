defmodule BillionOak.Repo.Migrations.CreateCustomerIngestions do
  use Ecto.Migration

  def change do
    create table(:customer_ingestions, primary_key: false) do
      add :id, :string, primary_key: true
      add :status, :string
      add :url, :string
      add :sha256, :string
      add :size_bytes, :string
      add :format, :string
      add :schema, :string

      timestamps(type: :utc_datetime)
    end
  end
end
