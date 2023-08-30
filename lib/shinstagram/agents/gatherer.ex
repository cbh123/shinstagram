defmodule Shinstagram.Agents.Gatherer do
  use GenServer

  @me Gatherer

  # api

  def start_link(profile_count) do
    GenServer.start_link(__MODULE__, profile_count, name: @me)
  end

  def done() do
    GenServer.cast(@me, :done)
  end

  # server

  def init(profile_count) do
    Process.send_after(self(), :kickoff, 0)
    {:ok, profile_count}
  end

  def handle_info(:kickoff, profile_count) do
    1..profile_count
    |> Enum.each(fn _ -> Shinstagram.ProfileSupervisor.add_profile() end)

    {:noreply, profile_count}
  end

  def handle_cast(:done, _profile_count = 1) do
    IO.puts("Profiles are done!")
    System.halt(0)
  end

  def handle_cast(:done, profile_count) do
    {:noreply, profile_count - 1}
  end
end
