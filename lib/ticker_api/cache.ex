defmodule TickerApi.Cache do
  @moduledoc false
  use Nebulex.Cache,
    otp_app: :ticker_api,
    adapter: Nebulex.Adapters.Redis
end
