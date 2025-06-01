defmodule TickerApiWeb.Api.TickerCsvController do
  use TickerApiWeb, :controller

  require Logger

  alias TickerApi.B3Tickers.B3TickersBucket

  def upload(conn, _params) do
    case B3TickersBucket.upload() do
      {:ok, presigned_url} ->
        conn
        |> put_status(:created)
        |> json(%{presigned_url: presigned_url})

      {:error, reason} ->
        Logger.error("Failed to generate presigned URL. Error: #{inspect(reason)}")

        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to generate presigned URL"})
    end
  end
end
