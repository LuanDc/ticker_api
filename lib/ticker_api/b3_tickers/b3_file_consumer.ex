defmodule TickerApi.B3FileConsumer do
  use Broadway

  NimbleCSV.define(CSV, separator: ";", escape: "\"")

  require Logger

  alias TickerApi.Ticker

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwaySQS.Producer,
           queue_url:
             "https://sqs.us-east-1.amazonaws.com/992382630574/ticker-file-uploaded-queue"}
      ],
      processors: [
        default: [concurrency: 2]
      ]
    )
  end

  @impl true
  def handle_message(_, %Broadway.Message{data: data} = message, _) when is_binary(data) do
    Logger.info("Processing message: #{inspect(data)}")

    data
    |> parse()
    |> process_message()

    message
  end

  defp parse(data) do
    data = Jason.decode!(data)
    Map.put(data, "Message", Jason.decode!(data["Message"]))
  end

  defp process_message(%{
         "Message" => %{"Records" => [%{"s3" => %{"bucket" => bucket, "object" => object}}]}
       }) do
    bucket_name = bucket["name"]
    file_name = object["key"]

    bucket_name
    |> read_from_s3_unziped(file_name)
    |> process_file()
  end

  defp read_from_s3_unziped(bucket_name, file_name) do
    aws_s3_config = ExAws.Config.new(:s3)
    file = Unzip.S3File.new(file_name, bucket_name, aws_s3_config)
    {:ok, unzip} = Unzip.new(file)
    file_name = String.replace_suffix(file_name, ".zip", "")
    Unzip.file_stream!(unzip, file_name)
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
