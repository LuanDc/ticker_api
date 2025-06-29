defmodule TickerApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TickerApi.PromEx,
      TickerApiWeb.Telemetry,
      TickerApi.Repo,
      TickerApi.Cache,
      {Oban, Application.fetch_env!(:ticker_api, Oban)},
      {DNSCluster, query: Application.get_env(:ticker_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TickerApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: TickerApi.Finch},
      # Start a worker by calling: TickerApi.Worker.start_link(arg)
      # {TickerApi.Worker, arg},
      # Start to serve requests, typically the last entry
      TickerApiWeb.Endpoint,
      TickerApi.B3FileUploaded
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TickerApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TickerApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
