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

  def read_from_s3_unziped(bucket_name, file_name) do
    aws_s3_config = ExAws.Config.new(:s3)
    file = Unzip.S3File.new(file_name, bucket_name, aws_s3_config)
    {:ok, unzip} = Unzip.new(file)
    file_name = String.replace_suffix(file_name, ".zip", "")
    Unzip.file_stream!(unzip, file_name)
  end
end
