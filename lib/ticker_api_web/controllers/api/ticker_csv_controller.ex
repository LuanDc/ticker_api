defmodule TickerApiWeb.Api.TickerCsvController do
  use TickerApiWeb, :controller

  alias TickerApi.B3Tickers.B3TickersBucket

  def upload(conn, %{"file" => file}) do
    :done = B3TickersBucket.upload!(file.path)

    conn
    |> put_status(:created)
    |> text("")
  end
end
