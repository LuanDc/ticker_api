defmodule TickerApi.B3Tickers.B3TickersBucket do
  alias TickerApi.B3Tickers.B3TickersBucketImpl

  @type upload_response :: map()

  @callback upload(binary()) :: upload_response()
  @callback read_from_s3_unziped(binary(), binary()) :: any()

  def upload(name) when is_binary(name) do
    b3_tickers_bucket().upload(name)
  end

  def read_from_s3_unziped(bucket_name, file_name) do
    b3_tickers_bucket().read_from_s3_unziped(bucket_name, file_name)
  end

  defp b3_tickers_bucket, do: Application.get_env(:ticker_api, __MODULE__, B3TickersBucketImpl)
end
