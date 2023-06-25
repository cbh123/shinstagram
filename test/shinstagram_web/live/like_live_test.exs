defmodule ShinstagramWeb.LikeLiveTest do
  use ShinstagramWeb.ConnCase

  import Phoenix.LiveViewTest
  import Shinstagram.TimelineFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_like(_) do
    like = like_fixture()
    %{like: like}
  end

  describe "Index" do
    setup [:create_like]

    test "lists all likes", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/likes")

      assert html =~ "Listing Timeline"
    end

    test "saves new like", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/likes")

      assert index_live |> element("a", "New Like") |> render_click() =~
               "New Like"

      assert_patch(index_live, ~p"/likes/new")

      assert index_live
             |> form("#like-form", like: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#like-form", like: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/likes")

      html = render(index_live)
      assert html =~ "Like created successfully"
    end

    test "updates like in listing", %{conn: conn, like: like} do
      {:ok, index_live, _html} = live(conn, ~p"/likes")

      assert index_live |> element("#likes-#{like.id} a", "Edit") |> render_click() =~
               "Edit Like"

      assert_patch(index_live, ~p"/likes/#{like}/edit")

      assert index_live
             |> form("#like-form", like: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#like-form", like: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/likes")

      html = render(index_live)
      assert html =~ "Like updated successfully"
    end

    test "deletes like in listing", %{conn: conn, like: like} do
      {:ok, index_live, _html} = live(conn, ~p"/likes")

      assert index_live |> element("#likes-#{like.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#likes-#{like.id}")
    end
  end

  describe "Show" do
    setup [:create_like]

    test "displays like", %{conn: conn, like: like} do
      {:ok, _show_live, html} = live(conn, ~p"/likes/#{like}")

      assert html =~ "Show Like"
    end

    test "updates like within modal", %{conn: conn, like: like} do
      {:ok, show_live, _html} = live(conn, ~p"/likes/#{like}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Like"

      assert_patch(show_live, ~p"/likes/#{like}/show/edit")

      assert show_live
             |> form("#like-form", like: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#like-form", like: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/likes/#{like}")

      html = render(show_live)
      assert html =~ "Like updated successfully"
    end
  end
end
