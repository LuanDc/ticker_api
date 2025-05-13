defmodule TickerApi.Repo do
  use Ecto.Repo,
    otp_app: :ticker_api,
    adapter: Ecto.Adapters.Postgres
end
