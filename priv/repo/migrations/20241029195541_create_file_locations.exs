defmodule BillionOak.Repo.Migrations.CreateFileLocations do
  use Ecto.Migration

  def change do
    create table(:file_locations, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string, null: false
      add :organization_id, :string
      add :owner_id, :string

      timestamps()
    end

    create index(:file_locations, :organization_id)
    create index(:file_locations, :owner_id)
  end
end
