defmodule TickerApi.TickerCsvControllerTest do
  use TickerApiWeb.ConnCase, async: true

  import Hammox

  setup :verify_on_exit!

  @presigned_url "https://example.com/presigned-url"

  test "returns a presigned URL to upload ticker file", %{conn: conn} do
    expect(B3TickersBucketMock, :upload, fn -> {:ok, @presigned_url} end)

    assert conn
           |> post(~p"/api/ticker_csv_file", %{})
           |> json_response(201) == %{"presigned_url" => @presigned_url}
  end

  test "returns an error when upload fails", %{conn: conn} do
    expect(B3TickersBucketMock, :upload, fn -> {:error, "Any reason"} end)

    assert conn
           |> post(~p"/api/ticker_csv_file", %{})
           |> json_response(500) == %{"error" => "Failed to generate presigned URL"}
  end
end
