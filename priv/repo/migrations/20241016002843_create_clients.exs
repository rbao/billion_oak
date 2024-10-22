defmodule BillionOak.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string
      add :organization_id, :string
      add :secret, :string
      add :wx_app_id, :string
      add :wx_app_secret, :string

      timestamps()
    end

    create index(:clients, :organization_id)
  end
end
