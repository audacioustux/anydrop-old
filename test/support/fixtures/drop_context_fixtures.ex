defmodule Anydrop.DropContextFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Anydrop.DropContext` context.
  """

  @doc """
  Generate a drop.
  """
  def drop_fixture(attrs \\ %{}) do
    {:ok, drop} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> Anydrop.DropContext.create_drop()

    drop
  end
end
