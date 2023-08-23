defmodule Shinstagram.Agents.Manager do
  @moduledoc """
  This agent manages all the agents.
  """
  use GenServer
  alias Shinstagram.Timeline
  alias Phoenix.PubSub

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    manage()
    {:ok, state}
  end

  defp manage() do
    PubSub.broadcast(Shinstagram.PubSub, "manager", {"status", "running"})
    Process.send_after(self(), :manager, 3000)
  end

  def handle_info(:manager, state) do
    manage()
    {:noreply, state}
  end
end
