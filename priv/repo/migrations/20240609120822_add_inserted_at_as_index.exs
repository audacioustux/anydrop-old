defmodule Anydrop.Repo.Migrations.AddInsertedAtAsIndex do
  use Ecto.Migration

  def change do
    create index(:drops, [:inserted_at])
  end
end
