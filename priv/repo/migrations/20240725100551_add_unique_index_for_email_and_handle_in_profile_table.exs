defmodule Anydrop.Repo.Migrations.AddUniqueIndexForEmailAndHandleInProfileTable do
  use Ecto.Migration

  def change do
    create unique_index(:profiles, [:email, :type], name: :profiles_email_type_index)
    create unique_index(:profiles, [:handle, :type], name: :profiles_handle_type_index)
  end
end
