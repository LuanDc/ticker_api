defmodule TickerApi.B3Tickers.B3TickersBucket do
  @callback upload!(String.t()) :: :done

  alias TickerApi.B3Tickers.B3TickersBucketImpl

  def upload!(path) do
    b3_tickers_bucket().upload!(path)
  end

  defp b3_tickers_bucket do
    Application.get_env(:ticker_api, __MODULE__, B3TickersBucketImpl)
  end
end
