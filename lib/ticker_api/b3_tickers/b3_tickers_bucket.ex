defmodule TickerApi.B3Tickers.B3TickersBucket do
  alias TickerApi.B3Tickers.B3TickersBucketImpl

  @type upload_response :: map()

  @callback upload(binary()) :: upload_response()

  def upload(name) when is_binary(name), do: b3_tickers_bucket().upload(name)

  defp b3_tickers_bucket, do: Application.get_env(:ticker_api, __MODULE__, B3TickersBucketImpl)
end
