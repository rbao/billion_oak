defmodule BillionOak.Repo.Migrations.CreateIngestionAttempts do
  use Ecto.Migration

  def change do
    create table(:ingestion_attempts, primary_key: false) do
      add :id, :string, primary_key: true
      add :company_id, :string, null: false
      add :organization_id, :string, null: false
      add :status, :string
      add :s3_key, :string
      add :sha256, :string
      add :size_bytes, :string
      add :format, :string
      add :schema, :string

      timestamps(type: :utc_datetime)
    end

    create index(:ingestion_attempts, :company_id)
    create index(:ingestion_attempts, :organization_id)
  end
end
