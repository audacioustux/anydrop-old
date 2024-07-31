defmodule Anydrop.DropContext.Drop do
  use Anydrop.Schema
  import Ecto.Changeset

  schema "drops" do
    field :body, :string
    field :is_deleted, :boolean, default: false

    belongs_to :profile, Anydrop.Accounts.Profile
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(drop, attrs) do
    drop
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> validate_length(:body, max: 500, min: 1)
  end

  def delete_changeset(drop, attrs) do
    drop
    |> cast(attrs, [:is_deleted])
  end
end
