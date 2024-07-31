defmodule Anydrop.Repo.Migrations.DropUsersAndDropsTable do
  use Ecto.Migration

  def change do
    drop table(:users)
    drop table(:drops)
  end
end
