defmodule Shinstagram.Agents.Manager do
  @moduledoc """
  This agent manages all the agents.
  """
  use GenServer
  alias Shinstagram.Timeline
  alias ShinstagramWeb.Endpoint

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    manage()
    {:ok, state}
  end

  defp manage() do
    # Process.send_after(self(), :manage, 5000)
  end

  def handle_info(:manager, state) do
    manage()
    {:noreply, state}
  end
end
