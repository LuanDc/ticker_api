defmodule TickerApi.B3FileUploaded do
  use Broadway

  NimbleCSV.define(CSV, separator: ";", escape: "\"")

  require Logger

  alias Broadway.Message

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
      ],
      batchers: [
        default: [concurrency: 2, batch_size: 5]
      ]
    )
  end

  @impl true
  def handle_message(_, %Broadway.Message{data: data} = message, _) when is_binary(data) do
    Logger.info("Processing message: #{inspect(data)}")

    Message.update_data(message, &parse/1)
  end

  @impl true
  def handle_batch(:default, messages, _batch_info, _context) do
    messages
    |> Enum.map(& &1.data)
    |> Enum.map(&TickerApi.B3FileIngestion.new/1)
    |> Oban.insert_all()

    messages
  end

  defp parse(data) do
    %{"Message" => message} = Jason.decode!(data)

    %{"Records" => [%{"s3" => %{"bucket" => bucket, "object" => object}}]} =
      Jason.decode!(message)

    %{"bucket" => bucket, "object" => object}
  end
end
