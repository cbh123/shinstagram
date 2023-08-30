defmodule Shinstagram.Agents.Manager do
  @moduledoc """
  This agent manages all the agents.
  """
  use GenServer
  alias Shinstagram.Timeline
  alias Shinstagram.Profiles
  alias Shinstagram.Repo
  alias Phoenix.PubSub

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    # manage()
    {:ok, state}
  end

  defp manage() do
    PubSub.broadcast(Shinstagram.PubSub, "manager", {"status", "started"})

    actions = [:post, :comment]

    action = actions |> Enum.random()
    profile = Profiles.get_random_profile()
    PubSub.broadcast(Shinstagram.PubSub, "manager", {action, "profile:#{profile.id}"})

    case action do
      :post ->
        {:ok, post} = Timeline.gen_post(profile)
        PubSub.broadcast(Shinstagram.PubSub, "manager", {action, post})

      :comment ->
        post = Timeline.list_recent_posts(1) |> List.first() |> Repo.preload(:profile)

        PubSub.broadcast(
          Shinstagram.PubSub,
          "profile:#{profile.id}",
          {action, "checking out post"}
        )

        {:ok, comment} = Timeline.gen_comment(profile, post)

        PubSub.broadcast(Shinstagram.PubSub, "manager", {action, comment})

      _ ->
        PubSub.broadcast(
          Shinstagram.PubSub,
          "profile:#{profile.id}",
          {action, "not yet implemented"}
        )
    end

    Process.send_after(self(), :manager, 3000)
  end

  def handle_info(:manager, state) do
    manage()
    {:noreply, state}
  end
end
