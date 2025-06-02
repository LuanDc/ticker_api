defmodule TickerApiWeb.Api.TickerCsvController do
  use TickerApiWeb, :controller

  require Logger

  alias TickerApi.B3Tickers.B3TickersBucket

  def upload(conn, params) do
    response = B3TickersBucket.upload(params["name"])

    conn
    |> put_status(:created)
    |> json(response)
  end
end
