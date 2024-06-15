defmodule Anydrop.Repo.Migrations.AddIsDeletedFieldToDrop do
  use Ecto.Migration

  def change do
    alter table(:drops) do
      add :is_deleted, :boolean, default: false
    end
  end
end
