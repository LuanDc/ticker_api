defmodule TickerApi.TickerCsvControllerTest do
  use TickerApiWeb.ConnCase, async: true

  import Hammox

  setup :verify_on_exit!

  test "uploads ticker csv file to the ticker csv bucket", %{conn: conn} do
    file =
      %Plug.Upload{
        content_type: "text/csv",
        filename: "29-04-2025_NEGOCIOSAVISTA.txt",
        path: "test/support/fixtures/29-04-2025_NEGOCIOSAVISTA.txt"
      }

    expect(B3TickersBucketMock, :upload!, fn path ->
      assert path == file.path
      :done
    end)

    assert conn
           |> post(~p"/api/ticker_csv_file", %{"file" => file})
           |> text_response(201)
  end
end
