defmodule TickerApi.B3FileUploadedTest do
  use TickerApi.DataCase
  use Oban.Testing, repo: TickerApi.Repo

  alias Ecto.Adapters.SQL.Sandbox

  @valid_message %{
    "Message" => %{
      "Records" => [
        %{
          "s3" => %{
            "bucket" => %{"name" => "test-bucket"},
            "object" => %{"key" => "test-file.txt.zip"}
          }
        }
      ]
    }
  }

  @invalid_message %{"invalid_key" => "invalid_value"}

  setup do
    :ok = Sandbox.checkout(TickerApi.Repo)
    Sandbox.mode(TickerApi.Repo, {:shared, self()})
    :ok
  end

  test "ack when message has valid payload" do
    ref = Broadway.test_message(TickerApi.B3FileUploaded, Jason.encode!(@valid_message))
    expected_data = %{"bucket" => "test-bucket", "file_name" => "test-file.txt.zip"}
    assert_receive {:ack, ^ref, [%Broadway.Message{data: ^expected_data}], []}
  end

  test "mark as failed messages which has invalid payload" do
    ref = Broadway.test_message(TickerApi.B3FileUploaded, Jason.encode!(@invalid_message))
    assert_receive {:ack, ^ref, [], [%Broadway.Message{status: {:failed, :invalid_payload}}]}
  end
end
