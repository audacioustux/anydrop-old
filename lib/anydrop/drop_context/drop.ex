defmodule Anydrop.DropContext.Drop do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drops" do
    field :body, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(drop, attrs) do
    drop
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
