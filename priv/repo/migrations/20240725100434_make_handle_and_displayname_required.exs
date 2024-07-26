defmodule Anydrop.Repo.Migrations.MakeHandleAndDisplaynameRequired do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      modify :handle, :string, null: false
      modify :display_name, :string, null: false
    end
  end
end
