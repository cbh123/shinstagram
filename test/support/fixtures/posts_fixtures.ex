defmodule Shinstagram.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shinstagram.Timeline` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        caption: "some caption",
        photo: "some photo"
      })
      |> Shinstagram.Timeline.create_post()

    post
  end
end
