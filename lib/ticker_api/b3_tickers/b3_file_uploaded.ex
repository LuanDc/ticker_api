defmodule TickerApi.B3FileUploaded do
  use Broadway

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
        default: [concurrency: 4]
      ],
      batchers: [
        file_uploaded_batch: [concurrency: 2, batch_size: 10]
      ]
    )
  end

  @impl true
  def handle_message(_, %Broadway.Message{data: data} = message, _) do
    Logger.info("Message consumed from ticker-file-uploaded-queue. Data: #{inspect(data)}")

    data
    |> parse_data()
    |> handle_message(message)
  end

  @impl true
  def handle_batch(:file_uploaded_batch, messages, _batch_info, _context) do
    messages
    |> Enum.map(& &1.data)
    |> Enum.map(&TickerApi.B3FileIngestion.new/1)
    |> Oban.insert_all()

    Logger.info("Batch of file uploaded messages processed successfully")

    messages
  end

  defp handle_message({:ok, parsed}, message) do
    message
    |> Message.put_batcher(:file_uploaded_batch)
    |> Message.update_data(fn _ -> parsed end)
  end

  defp handle_message({:error, reason}, message) do
    Logger.error(
      "Invalid payload for a message came from ticker-file-uploaded-queue: #{inspect(reason)}"
    )

    Message.failed(message, :invalid_payload)
  end

  defp parse_data(data) do
    with {:ok, %{"Message" => %{"Records" => records}}} <- Jason.decode(data),
         [%{"s3" => %{"bucket" => %{"name" => bucket_name}, "object" => %{"key" => file_name}}}] <-
           records do
      {:ok, %{"bucket" => bucket_name, "file_name" => file_name}}
    else
      error -> {:error, error}
    end
  end
end
