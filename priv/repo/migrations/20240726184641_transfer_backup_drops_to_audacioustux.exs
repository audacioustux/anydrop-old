defmodule Anydrop.Repo.Migrations.TransferBackupDropsToAudacioustux do
  use Ecto.Migration
  import Ecto.Query, only: [from: 2]

  def change do
    profile = Anydrop.Accounts.get_profile_by_handle!("audacioustux")
    backup = Anydrop.Repo.all(from a in "backup_drops", select: [:body, :is_deleted, :inserted_at, :updated_at])

    Enum.each(backup, fn b ->
      {:ok, iat} = DateTime.from_naive(b.inserted_at, "Etc/UTC")
      iat = DateTime.truncate(iat, :second)
      {:ok, uat} = DateTime.from_naive(b.updated_at, "Etc/UTC")
      uat = DateTime.truncate(uat, :second)
      profile
      |> Ecto.build_assoc(:drops, body: b.body, is_deleted: b.is_deleted, updated_at: uat, inserted_at: iat)
      |> Anydrop.Repo.insert()
    end)

  end
end
