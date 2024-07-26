defmodule Anydrop.Accounts.User do
  use Anydrop.Schema
  import Ecto.Changeset

  schema "users" do
    has_many :profiles, Anydrop.Accounts.Profile
    timestamps(type: :utc_datetime)
  end

  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [])
  end
end
