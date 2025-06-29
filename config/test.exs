import Config
config :ticker_api, Oban, testing: :manual

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ticker_api, TickerApi.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ticker_api_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ticker_api, TickerApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "QCeYnWEyMVtjoYIF294NZFg9b3F3k2kwXciq6Vv72Rtwzd6ZSkJsNi0vCWyAuRnL",
  server: false

# In test we don't send emails
config :ticker_api, TickerApi.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :ticker_api, TickerApi.B3FileUploaded,
  producer_module: Broadway.DummyProducer,
  producer_options: []

config :ex_aws,
  access_key_id: "access_key_id",
  secret_access_key: "secret_access_key"
