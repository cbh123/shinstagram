defmodule ShinstagramWeb.ProfileLive.Show do
  use ShinstagramWeb, :live_view

  alias Shinstagram.Profiles
  alias Shinstagram.Timeline

  @impl true
  def mount(%{"username" => username}, _session, socket) do
    profile = Profiles.get_profile_by_username!(username)

    {:ok,
     socket
     |> assign(:page_title, "View #{profile.name}'s profile on Shinstagram")
     |> assign(:profile, profile)
     |> stream(:posts, Timeline.list_posts_by_profile(profile))}
  end

  def handle_params(params, _url, socket) do
    {:noreply, socket}
  end
end
