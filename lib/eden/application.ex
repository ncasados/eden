defmodule Eden.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EdenWeb.Telemetry,
      Eden.Repo,
      {DNSCluster, query: Application.get_env(:eden, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Eden.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Eden.Finch},
      # Start a worker by calling: Eden.Worker.start_link(arg)
      # {Eden.Worker, arg},
      # Start to serve requests, typically the last entry
      EdenWeb.Endpoint,
      EDDNListener
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Eden.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EdenWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
