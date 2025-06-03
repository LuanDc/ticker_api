defmodule TickerApiWeb.Api.TickerCsvController do
  use TickerApiWeb, :controller

  require Logger

  alias TickerApi.B3Tickers.B3TickersBucket
  alias TickerApi.Tickers

  def create(conn, params) do
    response = B3TickersBucket.upload(params["name"])

    conn
    |> put_status(:created)
    |> json(response)
  end

  def show(conn, params) do
    ticker = Map.get(params, "ticker", "")
    start_date = Map.get(params, "start_date", "")

    task = Task.async(fn -> Tickers.get_max_quote(ticker, start_date) end)
    max_daily_volume = Tickers.get_max_daily_volume(ticker, start_date) || 0
    max_range_value = Task.await(task) || 0

    json(conn, %{
      ticker: ticker,
      max_daily_volume: max_daily_volume,
      max_range_value: max_range_value
    })
  end
end
