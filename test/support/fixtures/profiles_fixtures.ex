defmodule Shinstagram.ProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shinstagram.Profiles` context.
  """

  @doc """
  Generate a profile.
  """
  def profile_fixture(attrs \\ %{}) do
    {:ok, profile} =
      attrs
      |> Enum.into(%{
        name: "some name",
        profile_photo: "some profile_photo"
      })
      |> Shinstagram.Profiles.create_profile()

    profile
  end
end
