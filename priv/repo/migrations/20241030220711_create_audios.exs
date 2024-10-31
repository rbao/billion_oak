defmodule BillionOak.Repo.Migrations.CreateAudios do
  use Ecto.Migration

  def change do
    create table(:audios, primary_key: false) do
      add :id, :string, primary_key: true
      add :status, :string, null: false
      add :number, :string
      add :duration_seconds, :integer
      add :bit_rate, :integer
      add :title, :string
      add :speaker_names, :string
      add :primary_file_id, :string, null: false
      add :cover_image_file_id, :string
      add :organization_id, :string, null: false

      timestamps()
    end
  end
end
