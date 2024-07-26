defmodule Anydrop.Repo.Migrations.CopyCurrentDropsToBackupTable do
  use Ecto.Migration
  import Ecto.Query, only: [from: 2]

  def change do
    drops = Anydrop.Repo.all(from d in Anydrop.DropContext.Drop, select: [:body, :is_deleted, :inserted_at, :updated_at])
    drops = Enum.map(drops, fn drop ->
      %{id: Uniq.UUID.string_to_binary!(Uniq.UUID.uuid7()),
      body: drop.body,
      is_deleted: drop.is_deleted,
      inserted_at: drop.inserted_at,
      updated_at: drop.updated_at}
    end)
    Anydrop.Repo.insert_all("backup_drops", drops)
  end
end
