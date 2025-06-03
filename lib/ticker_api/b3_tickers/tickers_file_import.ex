defmodule TickerApi.TickersFilePartitioner do
  use Broadway

  NimbleCSV.define(CSV, separator: ";", escape: "\"")

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwaySQS.Producer,
           queue_url: "queue_url",
           config: [
             access_key_id: "access_key_id",
             secret_access_key: "secret_access_key"
           ]}
      ],
      processors: [
        default: [concurrency: 2]
      ]
    )
  end

  @impl true
  def handle_message(_, %Broadway.Message{data: data} = message, _) when is_binary(data) do
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
    |> Task.async_stream(fn stream ->
      stream
      |> Stream.map(&IO.iodata_to_binary/1)
      |> CSV.to_line_stream()
      |> CSV.parse_stream(skip_headers: true)
      |> Stream.map(&parse_raw/1)
      |> Stream.map(&IO.inspect/1)
      |> Stream.chunk_every(100)
      |> Stream.map(&IO.inspect/1)
      |> Stream.map(
        &TickerApi.Repo.insert_all(InvestimentPlatform.Ticker, &1, on_conflict: :nothing)
      )
      |> Stream.run()
    end)
    |> Stream.run()
  end

  defp parse_raw(row) do
    closing_time = Enum.at(row, 5)
    ticker = Enum.at(row, 1)

    date = Enum.at(row, 0) |> Date.from_iso8601!()
    {price, _} = Enum.at(row, 3) |> Float.parse()
    {amount, _} = Enum.at(row, 4) |> Integer.parse()

    event_id = generate_event_id(row)

    %{
      closing_time: closing_time,
      ticker: ticker,
      price: price,
      date: date,
      amount: amount,
      event_id: event_id
    }
  end

  defp generate_event_id(row) do
    sha256 = :crypto.hash(:sha256, row)
    Base.encode16(sha256, case: :lower)
  end
end
