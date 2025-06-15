defmodule TickerApi.B3FileIngestion do
  use Oban.Worker,
    queue: :b3_file_ingestion,
    max_attempts: 5

  require Logger

  alias TickerApi.B3Tickers.{B3FileRaw, B3TickersBucket}
  alias TickerApi.Tickers

  NimbleCSV.define(CSV, separator: ";", escape: "\"")

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"bucket" => bucket, "file_name" => file_name}}) do
    Logger.info("Processing file from bucket: #{bucket}, file_name: #{file_name}")

    bucket
    |> B3TickersBucket.read_from_s3_unziped(file_name)
    |> Task.async_stream(&process_file/1, timeout: 300_000)
    |> Stream.run()
  end

  defp process_file(stream) do
    stream
    |> Stream.map(&IO.iodata_to_binary/1)
    |> CSV.to_line_stream()
    |> CSV.parse_stream(skip_headers: true)
    |> Stream.chunk_every(100)
    |> Stream.map(&insert_chuck/1)
    |> Stream.run()
  end

  defp insert_chuck(chuck) do
    chuck
    |> Enum.map(&B3FileRaw.parse_raw/1)
    |> Enum.filter(&(&1 != []))
    |> Tickers.insert_all()
  end
end
