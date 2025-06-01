defmodule TickerApi.B3Tickers.B3TickersBucketImpl do
  @spec upload :: {:ok, String.t()} | {:error, any()}
  def upload do
    :s3
    |> ExAws.Config.new()
    |> ExAws.S3.presigned_url(:post, "b3-tickers", "/", [])
  end
end
