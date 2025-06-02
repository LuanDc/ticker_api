defmodule TickerApi.B3Tickers.B3TickersBucketImpl do
  @dialyzer {:no_return, upload: 1}
  def upload(name) when is_binary(name) do
    :s3
    |> ExAws.Config.new()
    |> ExAws.S3.presigned_post("b3-tickers", name,
      virtual_host: true,
      content_type: "application/zip",
      expires_in: 3600
    )
  end
end
