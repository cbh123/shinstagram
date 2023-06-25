defmodule Shinstagram.Agents.Liker do
  @moduledoc """
  This agent looks at recent photos and decides which profiles would like them.
  """
  use GenServer
  alias Shinstagram.Timeline
  alias ShinstagramWeb.Endpoint

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    # schedule_liker()
    {:ok, state}
  end

  defp schedule_liker() do
    # Process.send_after(self(), :like, 5000)
  end

  def handle_info(info, socket) do
    IO.inspect(info, label: "")
    {:noreply, socket}
  end

  def handle_info(:like, state) do
    profiles = Shinstagram.Profiles.list_profiles()
    recent_posts = Shinstagram.Timeline.list_recent_posts(5)

    recent_posts
    |> Enum.map(fn post ->
      liker = profiles |> Enum.random()

      profiles_who_already_liked =
        Timeline.get_likes_by_post_id(post.id) |> Enum.map(fn l -> l.profile_id end)

      if liker.id not in profiles_who_already_liked do
        {:ok, _like} = Timeline.create_like(liker, post)
      end
    end)

    schedule_liker()
    {:noreply, state}
  end
end
