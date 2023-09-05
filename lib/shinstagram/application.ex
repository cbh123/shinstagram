defmodule Shinstagram.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ShinstagramWeb.Telemetry,
      # Start the Ecto repository
      Shinstagram.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Shinstagram.PubSub},
      # Start Finch
      {Finch, name: Shinstagram.Finch},
      # Start the Endpoint (http/https)
      ShinstagramWeb.Endpoint,
      # Start AI stuff
      Shinstagram.ProfileSupervisor,
      {Shinstagram.Agents.Gatherer, 5}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Shinstagram.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShinstagramWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
