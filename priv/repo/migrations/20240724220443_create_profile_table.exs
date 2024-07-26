defmodule Anydrop.Repo.Migrations.CreateProfileTable do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:profiles) do
      add :email, :citext, null: false
      add :handle, :string
      add :display_name, :string
      add :type, :string

      add :user_id, references(:users, on_delete: :nothing)
      timestamps(type: :utc_datetime)
    end
  end
end
