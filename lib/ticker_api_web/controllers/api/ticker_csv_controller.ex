defmodule TickerApiWeb.Api.TickerCsvController do
  use TickerApiWeb, :controller

  alias TickerApi.B3Tickers.B3TickersBucket

  def upload(conn, %{"file" => file}) do
    binary = File.read!(file.path)
    %{status_code: 200} = B3TickersBucket.upload!(file.path, binary)

    conn
    |> put_status(:created)
    |> text("")
  end
end
