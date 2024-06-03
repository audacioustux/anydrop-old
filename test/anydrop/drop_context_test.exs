defmodule Anydrop.DropContextTest do
  use Anydrop.DataCase

  alias Anydrop.DropContext

  describe "drops" do
    alias Anydrop.DropContext.Drop

    import Anydrop.DropContextFixtures

    @invalid_attrs %{body: nil}

    test "list_drops/0 returns all drops" do
      drop = drop_fixture()
      assert DropContext.list_drops() == [drop]
    end

    test "get_drop!/1 returns the drop with given id" do
      drop = drop_fixture()
      assert DropContext.get_drop!(drop.id) == drop
    end

    test "create_drop/1 with valid data creates a drop" do
      valid_attrs = %{body: "some body"}

      assert {:ok, %Drop{} = drop} = DropContext.create_drop(valid_attrs)
      assert drop.body == "some body"
    end

    test "create_drop/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DropContext.create_drop(@invalid_attrs)
    end

    test "update_drop/2 with valid data updates the drop" do
      drop = drop_fixture()
      update_attrs = %{body: "some updated body"}

      assert {:ok, %Drop{} = drop} = DropContext.update_drop(drop, update_attrs)
      assert drop.body == "some updated body"
    end

    test "update_drop/2 with invalid data returns error changeset" do
      drop = drop_fixture()
      assert {:error, %Ecto.Changeset{}} = DropContext.update_drop(drop, @invalid_attrs)
      assert drop == DropContext.get_drop!(drop.id)
    end

    test "delete_drop/1 deletes the drop" do
      drop = drop_fixture()
      assert {:ok, %Drop{}} = DropContext.delete_drop(drop)
      assert_raise Ecto.NoResultsError, fn -> DropContext.get_drop!(drop.id) end
    end

    test "change_drop/1 returns a drop changeset" do
      drop = drop_fixture()
      assert %Ecto.Changeset{} = DropContext.change_drop(drop)
    end
  end
end
