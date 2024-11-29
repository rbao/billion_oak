defmodule BillionOak.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files, primary_key: false) do
      add :id, :string, primary_key: true
      add :status, :string
      add :name, :string
      add :content_type, :string
      add :size_bytes, :integer
      add :organization_id, :string
      add :owner_id, :string

      timestamps()
    end

    create index(:files, [:organization_id, :status])
  end
end
