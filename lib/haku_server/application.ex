defmodule HakuServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HakuServerWeb.Telemetry,
      HakuServer.Repo,
      {Oban, Application.fetch_env!(:genius_monad, Oban)},
      {DNSCluster, query: Application.get_env(:haku_server, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: HakuServer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: HakuServer.Finch},
      # Start a worker by calling: HakuServer.Worker.start_link(arg)
      # {HakuServer.Worker, arg},
      # Start to serve requests, typically the last entry
      HakuServerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HakuServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HakuServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
