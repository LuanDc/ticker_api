defmodule TickerApi.B3FileUploadedTest do
  use TickerApi.DataCase

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TickerApi.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(TickerApi.Repo, {:shared, self()})

    records = [
      %{
        "s3" => %{
          "bucket" => %{"name" => "test-bucket"},
          "object" => %{"key" => "test-file.txt.zip"}
        }
      }
    ]

    %{message: Jason.encode!(%{"Message" => %{"Records" => records}})}
  end

  test "consume and ack successfully a message with valid data", %{message: message} do
    ref = Broadway.test_message(TickerApi.B3FileUploaded, message)

    assert_receive {:ack, ^ref,
                    [
                      %Broadway.Message{
                        data: %{
                          "bucket" => "test-bucket",
                          "file_name" => "test-file.txt.zip"
                        }
                      }
                    ], []}
  end
end
