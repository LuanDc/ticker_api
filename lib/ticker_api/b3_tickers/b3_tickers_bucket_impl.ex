defmodule TickerApi.B3Tickers.B3TickersBucketImpl do
  alias ExAws.S3

  @spec upload!(String.t()) :: :done
  def upload!(path) do
    path
    |> S3.Upload.stream_file()
    |> S3.upload("tickers-bucket", "/")
    |> ExAws.request!()
  end
end
