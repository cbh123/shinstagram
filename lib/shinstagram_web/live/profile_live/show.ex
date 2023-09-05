defmodule ShinstagramWeb.ProfileLive.Show do
  use ShinstagramWeb, :live_view

  alias Shinstagram.Profiles
  alias Shinstagram.Timeline
  alias Shinstagram.Logs
  alias Shinstagram.Logs.Log

  @impl true
  def mount(%{"username" => username}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Shinstagram.PubSub, "feed")
    end

    profile = Profiles.get_profile_by_username!(username)
    logs = Logs.list_logs_by_profile(profile)

    {:ok,
     socket
     |> assign(profile: profile)
     |> assign(:page_title, "View #{profile.name}'s profile on Shinstagram")
     |> stream(:posts, Timeline.list_posts_by_profile(profile))
     |> stream(:logs, logs)}
  end

  def handle_info({"profile_activity", _event, log}, socket) do
    if log.profile_id == socket.assigns.profile.id do
      {:noreply, socket |> stream_insert(:logs, log, at: 0)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("sleep", %{"pid" => pid_string}, socket) do
    {:ok, profile} =
      pid_string
      |> String.replace("#PID", "")
      |> String.to_charlist()
      |> :erlang.list_to_pid()
      |> Shinstagram.Agents.Profile.shutdown_profile(30_000)

    {:noreply, socket |> assign(profile: profile)}
  end

  def handle_event("wake-up", _, %{assigns: %{profile: profile}} = socket) do
    {:ok, profile} = Shinstagram.ProfileSupervisor.add_profile(profile)
    {:noreply, socket |> assign(profile: profile)}
  end
end
