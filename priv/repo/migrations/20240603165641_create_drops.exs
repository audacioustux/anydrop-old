defmodule Anydrop.Repo.Migrations.CreateDrops do
  use Ecto.Migration

  def change do
    create table(:drops) do
      add :body, :text

      timestamps(type: :utc_datetime)
    end
  end
end
