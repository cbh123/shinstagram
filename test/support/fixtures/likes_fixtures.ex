defmodule Shinstagram.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shinstagram.Timeline` context.
  """

  @doc """
  Generate a like.
  """
  def like_fixture(attrs \\ %{}) do
    {:ok, like} =
      attrs
      |> Enum.into(%{})
      |> Shinstagram.Timeline.create_like()

    like
  end
end
