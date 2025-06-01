defmodule TickerApi.B3Tickers.B3TickersBucket do
  @callback upload() :: {:ok, String.t()} | {:error, any()}

  alias TickerApi.B3Tickers.B3TickersBucketImpl

  def upload, do: b3_tickers_bucket().upload()

  defp b3_tickers_bucket,
    do: Application.get_env(:ticker_api, __MODULE__, B3TickersBucketImpl)
end
