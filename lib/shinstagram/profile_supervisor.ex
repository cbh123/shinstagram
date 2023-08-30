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
    IO.puts("!! STARTING UP !!")
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_profile do
    profile = Shinstagram.Profiles.get_random_profile()

    {:ok, _pid} = DynamicSupervisor.start_child(@me, {Shinstagram.Agents.Profile, profile})
  end

  def kill_everyone do
    IO.puts("SHUTTING DOWN!!!")
    DynamicSupervisor.stop(@me, :commanded)
  end
end
