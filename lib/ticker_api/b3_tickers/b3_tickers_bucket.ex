defmodule TickerApi.B3Tickers.B3TickersBucket do
  @type response :: %{body: String.t(), headers: list(), status_code: integer()}
  @callback upload!(String.t(), binary()) :: response()

  alias TickerApi.B3Tickers.B3TickersBucketImpl

  def upload!(path, binary) do
    b3_tickers_bucket().upload!(path, binary)
  end

  defp b3_tickers_bucket do
    Application.get_env(:ticker_api, __MODULE__, B3TickersBucketImpl)
  end
end
