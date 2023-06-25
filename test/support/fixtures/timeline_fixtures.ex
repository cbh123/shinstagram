defmodule Shinstagram.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shinstagram.Timeline` context.
  """

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> Shinstagram.Timeline.create_comment()

    comment
  end
end
