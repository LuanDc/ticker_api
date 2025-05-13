Hammox.defmock(B3TickersBucketMock, for: TickerApi.B3Tickers.B3TickersBucket)
Application.put_env(:ticker_api, TickerApi.B3Tickers.B3TickersBucket, B3TickersBucketMock)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(TickerApi.Repo, :manual)
