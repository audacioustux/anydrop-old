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

  def list_drops([offset: offset, limit: limit, handle: handle]) do
    profile = Anydrop.Accounts.get_profile_by_handle!(handle)

    Drop
    |> where([d], d.is_deleted == false and d.profile_id == ^profile.id)
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
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
  def create_drop(handle, attrs \\ %{}) do
    profile = Anydrop.Accounts.get_profile_by_handle!(handle)

    profile
    |> Ecto.build_assoc(:drops)
    |> Drop.changeset(attrs)
    |> Repo.insert()
    |> broadcast()
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

  def update_is_deleted_drop(%Drop{} = drop, attrs \\ %{is_deleted: true}) do
    drop
    |> Drop.delete_changeset(attrs)
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


  def broadcast({:ok, drop}) do
    message = {:message_dropped, drop}

    Phoenix.PubSub.broadcast(Anydrop.PubSub, "drop_topic", message)

    {:ok, drop}
  end

  def broadcast({:error, changeset}), do: {:error, changeset}

  def subscribe do
    Phoenix.PubSub.subscribe(Anydrop.PubSub, "drop_topic")
  end
end
