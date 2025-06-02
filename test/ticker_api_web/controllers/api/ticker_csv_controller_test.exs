defmodule TickerApi.TickerCsvControllerTest do
  use TickerApiWeb.ConnCase, async: true

  import Hammox

  setup :verify_on_exit!

  @response %{
    "fields" => %{
      "Policy" =>
        "eyJjb25kaXRpb25zIjpbeyJYLUFtei1BbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJYLUFtei1DcmVkZW50aWFsIjoidGVzdC8yMDI1MDYwMi91cy1lYXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJYLUFtei1EYXRlIjoiMjAyNTA2MDJUMjAzODIwWiJ9LHsiYnVja2V0IjoiYjMtdGlja2VycyJ9LHsia2V5IjoiZmlsZV91cGxvYWRlZC50eHQuemlwIn1dLCJleHBpcmF0aW9uIjoiMjAyNS0wNi0wMlQyMTozODoyMC43NzI2NjZaIn0=",
      "X-Amz-Algorithm" => "AWS4-HMAC-SHA256",
      "X-Amz-Credential" => "test/20250602/us-east-1/s3/aws4_request",
      "X-Amz-Date" => "20250602T203820Z",
      "X-Amz-Signature" => "879cf28281f77a1054f4ab9791fc2745e8fb4eab1a117178555d4d3d61626175",
      "key" => "ticker_file.txt.zip"
    },
    "url" => "http://b3-tickers.localhost:4566"
  }

  test "returns a presigned URL to upload ticker file", %{conn: conn} do
    expect(B3TickersBucketMock, :upload, fn _name -> @response end)

    assert conn
           |> post(~p"/api/ticker_csv_file", %{"name" => "ticker_file.txt.zip"})
           |> json_response(201) == @response
  end
end
