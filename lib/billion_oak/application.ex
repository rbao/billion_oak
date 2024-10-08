defmodule BillionOak.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BillionOakWeb.Telemetry,
      BillionOak.Repo,
      {DNSCluster, query: Application.get_env(:billion_oak, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BillionOak.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BillionOak.Finch},
      # Start a worker by calling: BillionOak.Worker.start_link(arg)
      # {BillionOak.Worker, arg},
      # Start to serve requests, typically the last entry
      BillionOakWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BillionOak.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BillionOakWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
