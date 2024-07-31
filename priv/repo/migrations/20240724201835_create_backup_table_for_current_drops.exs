defmodule Anydrop.Repo.Migrations.CreateBackupTableForCurrentDrops do
  use Ecto.Migration

  def change do
    create table(:backup_drops) do
      add :body, :text
      add :is_deleted, :boolean, default: false

      timestamps(type: :utc_datetime)
    end
  end
end
