defmodule TickerApi.B3Tickers.B3FileRaw do
  def parse_raw([date, ticker, _, price, amount, closing_time | _rest] = row) do
    %{
      closing_time: closing_time,
      ticker: ticker,
      price: parse_price(price),
      date: Date.from_iso8601!(date),
      amount: parse_amount(amount),
      event_id: generate_event_id(row)
    }
  end

  def parse_raw(_row), do: []

  def parse_price(nil), do: nil

  def parse_price(price) do
    case Float.parse(price) do
      {price, _} -> price
      :error -> nil
    end
  end

  def parse_amount(nil), do: nil

  def parse_amount(amount) do
    case Integer.parse(amount) do
      {amount, _} -> amount
      :error -> nil
    end
  end

  defp generate_event_id(row) do
    sha256 = :crypto.hash(:sha256, row)
    Base.encode16(sha256, case: :lower)
  end
end
