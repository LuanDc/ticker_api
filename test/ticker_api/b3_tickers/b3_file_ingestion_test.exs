defmodule TickerApi.B3FileIngestionTest do
  use TickerApi.DataCase
  use Oban.Testing, repo: TickerApi.Repo

  import Hammox

  alias TickerApi.B3FileIngestion
  alias TickerApi.Ticker

  setup :verify_on_exit!

  test "processes file from S3 and inserts tickers" do
    args = %{"bucket" => "test-bucket", "file_name" => "test-file.txt.zip"}

    expect(B3TickersBucketMock, :read_from_s3_unziped, fn bucket_name, file_name ->
      assert bucket_name == args["bucket"]
      assert file_name == args["file_name"]

      zip_file = Unzip.LocalFile.open("./test/support/fixture/29-04-2025_NEGOCIOSAVISTA.txt.zip")
      {:ok, unzip} = Unzip.new(zip_file)
      Unzip.file_stream!(unzip, "29-04-2025_NEGOCIOSAVISTA.txt")
    end)

    assert count_tickers() == 0
    assert perform_job(B3FileIngestion, args) == :ok
    assert count_tickers() > 0
  end

  defp count_tickers, do: Repo.aggregate(Ticker, :count)
end
