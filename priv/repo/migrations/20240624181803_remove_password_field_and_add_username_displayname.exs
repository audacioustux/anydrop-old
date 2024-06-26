defmodule Anydrop.Repo.Migrations.RemovePasswordFieldAndAddUsernameDisplayname do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :hashed_password
      remove :confirmed_at
      add :username, :string
      add :display_name, :string
    end
  end
end
