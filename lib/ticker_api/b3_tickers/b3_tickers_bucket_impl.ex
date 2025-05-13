defmodule TickerApi.B3Tickers.B3TickersBucketImpl do
  @spec upload!(String.t(), binary()) :: :done
  def upload!(filename, image_binary) do
    "b3-stock-quotes"
    |> ExAws.S3.put_object(filename, image_binary)
    |> ExAws.request!()
  end
end
