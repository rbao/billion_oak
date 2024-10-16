defmodule BillionOak.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
      add :organization_id, :string
      add :refresh_token, :string

      timestamps()
    end

    create index(:clients, :organization_id)
    create unique_index(:clients, :refresh_token)
  end
end
