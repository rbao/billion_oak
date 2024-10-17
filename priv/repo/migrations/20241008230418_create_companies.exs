defmodule BillionOak.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies, primary_key: false) do
      add :id, :string, primary_key: true
      add :handle, :string, null: false
      add :name, :string, null: false

      timestamps()
    end

    create unique_index(:companies, [:handle])
  end
end
