defmodule Shinstagram.ProfileSupervisor do
  use DynamicSupervisor

  @moduledoc """
  This profile supervisor allows us to create an arbitrary number of profile agents at runtime.
  """

  @me ProfileSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: @me)
  end

  def init(:no_args) do
    Shinstagram.Profiles.reset_all_pids()
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_profile(profile) do
    {:ok, pid} = DynamicSupervisor.start_child(@me, {Shinstagram.Agents.Profile, profile})
    Shinstagram.Profiles.update_profile(profile, %{pid: inspect(pid)})
  end

  def add_asleep_profile() do
    profile = Shinstagram.Profiles.get_random_asleep_profile()
    {:ok, pid} = DynamicSupervisor.start_child(@me, {Shinstagram.Agents.Profile, profile})
    Shinstagram.Profiles.update_profile(profile, %{pid: inspect(pid)})
  end
end
