# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ticker_api,
  ecto_repos: [TickerApi.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :ticker_api, TickerApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TickerApiWeb.ErrorHTML, json: TickerApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TickerApi.PubSub,
  live_view: [signing_salt: "WfeCuUt0"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :ticker_api, TickerApi.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  ticker_api: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  ticker_api: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

# Configures PromEx
config :ticker_api, TickerApi.PromEx,
  manual_metrics_start_delay: :no_delay,
  grafana: [
    host: "http://localhost:3000",
    upload_dashboards_on_start: true,
    folder_name: "TickerApi Dashboards",
    annotate_app_lifecycle: true,
    auth_token: "auth_token"
  ]

config :ticker_api, TickerApi.Cache,
  conn_opts: [
    host: "127.0.0.1",
    port: 6379
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
