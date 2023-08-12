defmodule Shinstagram.TimelineTest do
  use Shinstagram.DataCase

  alias Shinstagram.Timeline

  describe "comments" do
    alias Shinstagram.Timeline.Comment

    import Shinstagram.TimelineFixtures

    @invalid_attrs %{body: nil}
    @profile = Profiles.get_profile_by_username!("qq")

    test "change_comment/1 returns a comment changeset" do
      assert @profile.username == "qq"
      Shinstagram.Timeline.create_image_prompt(profile)
    end
  end
end
