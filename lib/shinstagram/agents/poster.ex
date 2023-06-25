defmodule Shinstagram.Agents.Poster do
  @moduledoc """
  This agent posts new photos for profiles who are ready to post.
  """
  use GenServer

  def first_part do
    ["a cow eating a", "robot looking at a"]
  end

  def second_part do
    ["marshmallow", "spaghetti"]
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_post()
    {:ok, state}
  end

  defp schedule_post() do
    # Process.send_after(self(), :post, 5000)
  end

  def handle_info(:post, state) do
    Shinstagram.Profiles.list_profiles()
    |> Enum.map(fn profile ->
      photo_prompt = "#{first_part() |> Enum.random()} #{second_part |> Enum.random()}"

      Shinstagram.Timeline.create_post(profile, %{
        photo: "hi there!",
        caption: "cool",
        photo_prompt: photo_prompt
      })
    end)

    {:noreply, state}
  end
end
