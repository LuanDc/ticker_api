defmodule TickerApi.B3FileIngestion do
  use Oban.Worker,
    queue: :b3_file_ingestion,
    max_attempts: 5

  require Logger

  alias TickerApi.B3Tickers.B3TickersBucket
  alias TickerApi.Ticker

  NimbleCSV.define(CSV, separator: ";", escape: "\"")

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"bucket" => bucket, "file_name" => file_name}}) do
    Logger.info("Processing file from bucket: #{bucket}, file_name: #{file_name}")

    bucket
    |> B3TickersBucket.read_from_s3_unziped(file_name)
    |> process_file()

    :ok
  end

  defp process_file(stream) do
    stream
    |> Task.async_stream(
      fn stream ->
        stream
        |> Stream.map(&IO.iodata_to_binary/1)
        |> CSV.to_line_stream()
        |> CSV.parse_stream(skip_headers: true)
        |> Stream.map(&parse_raw/1)
        |> Stream.chunk_every(100)
        |> Stream.map(&TickerApi.Repo.insert_all(Ticker, &1, on_conflict: :nothing))
        |> Stream.run()
      end,
      timeout: 300_000
    )
    |> Stream.run()
  end

  defp parse_raw([date, ticker, _, price, amount, closing_time | _rest] = row) do
    %{
      closing_time: closing_time,
      ticker: ticker,
      price: parse_price(price),
      date: Date.from_iso8601!(date),
      amount: parse_amount(amount),
      event_id: generate_event_id(row)
    }
  end

  defp parse_raw(_row), do: []

  def parse_price(nil), do: nil

  def parse_price(price) do
    case Float.parse(price) do
      {price, _} -> price
      :error -> nil
    end
  end

  def parse_amount(nil), do: nil

  def parse_amount(amount) do
    case Integer.parse(amount) do
      {amount, _} -> amount
      :error -> nil
    end
  end

  defp generate_event_id(row) do
    sha256 = :crypto.hash(:sha256, row)
    Base.encode16(sha256, case: :lower)
  end
end
