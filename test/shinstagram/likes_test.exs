defmodule Shinstagram.TimelineTest do
  use Shinstagram.DataCase

  alias Shinstagram.Timeline

  describe "likes" do
    alias Shinstagram.Timeline.Like

    import Shinstagram.TimelineFixtures

    @invalid_attrs %{}

    test "list_likes/0 returns all likes" do
      like = like_fixture()
      assert Timeline.list_likes() == [like]
    end

    test "get_like!/1 returns the like with given id" do
      like = like_fixture()
      assert Timeline.get_like!(like.id) == like
    end

    test "create_like/1 with valid data creates a like" do
      valid_attrs = %{}

      assert {:ok, %Like{} = like} = Timeline.create_like(valid_attrs)
    end

    test "create_like/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_like(@invalid_attrs)
    end

    test "update_like/2 with valid data updates the like" do
      like = like_fixture()
      update_attrs = %{}

      assert {:ok, %Like{} = like} = Timeline.update_like(like, update_attrs)
    end

    test "update_like/2 with invalid data returns error changeset" do
      like = like_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_like(like, @invalid_attrs)
      assert like == Timeline.get_like!(like.id)
    end

    test "delete_like/1 deletes the like" do
      like = like_fixture()
      assert {:ok, %Like{}} = Timeline.delete_like(like)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_like!(like.id) end
    end

    test "change_like/1 returns a like changeset" do
      like = like_fixture()
      assert %Ecto.Changeset{} = Timeline.change_like(like)
    end
  end
end
