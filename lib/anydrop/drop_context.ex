defmodule Anydrop.DropContext do
  @moduledoc """
  The DropContext context.
  """

  import Ecto.Query, warn: false
  alias Anydrop.Repo

  alias Anydrop.DropContext.Drop

  @doc """
  Returns the list of drops.

  ## Examples

      iex> list_drops()
      [%Drop{}, ...]

  """
  def list_drops do
    Repo.all(Drop)
  end

  @doc """
  Gets a single drop.

  Raises `Ecto.NoResultsError` if the Drop does not exist.

  ## Examples

      iex> get_drop!(123)
      %Drop{}

      iex> get_drop!(456)
      ** (Ecto.NoResultsError)

  """
  def get_drop!(id), do: Repo.get!(Drop, id)

  @doc """
  Creates a drop.

  ## Examples

      iex> create_drop(%{field: value})
      {:ok, %Drop{}}

      iex> create_drop(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_drop(attrs \\ %{}) do
    %Drop{}
    |> Drop.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a drop.

  ## Examples

      iex> update_drop(drop, %{field: new_value})
      {:ok, %Drop{}}

      iex> update_drop(drop, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_drop(%Drop{} = drop, attrs) do
    drop
    |> Drop.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a drop.

  ## Examples

      iex> delete_drop(drop)
      {:ok, %Drop{}}

      iex> delete_drop(drop)
      {:error, %Ecto.Changeset{}}

  """
  def delete_drop(%Drop{} = drop) do
    Repo.delete(drop)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking drop changes.

  ## Examples

      iex> change_drop(drop)
      %Ecto.Changeset{data: %Drop{}}

  """
  def change_drop(%Drop{} = drop, attrs \\ %{}) do
    Drop.changeset(drop, attrs)
  end
end
