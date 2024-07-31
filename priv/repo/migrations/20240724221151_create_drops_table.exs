defmodule Anydrop.Repo.Migrations.CreateDropsTable do
  use Ecto.Migration

  def change do
    create table(:drops) do
      add :body, :text
      add :is_deleted, :boolean, default: false

      add :profile_id, references(:profiles, on_delete: :nothing)
      timestamps(type: :utc_datetime)
    end
  end
end
