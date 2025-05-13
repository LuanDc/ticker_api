defmodule TickerApi.TickerCsvControllerTest do
  use TickerApiWeb.ConnCase, async: true

  import Hammox

  setup :verify_on_exit!

  test "uploads ticker csv file to the ticker csv bucket", %{conn: conn} do
    file =
      %Plug.Upload{
        content_type: "application/zip",
        filename: "29-04-2025_NEGOCIOSAVISTA.txt.zip",
        path: "test/support/fixture/29-04-2025_NEGOCIOSAVISTA.txt.zip"
      }

    expect(B3TickersBucketMock, :upload!, fn path, _image_binary ->
      assert path == file.path
      %{body: "", headers: [{"Content-Length", "0"}], status_code: 200}
    end)

    assert conn
           |> post(~p"/api/ticker_csv_file", %{"file" => file})
           |> text_response(201)
  end
end
