defmodule TickerApi.Tickers do
  use Nebulex.Caching
  import Ecto.Query

  alias TickerApi.{Cache, Repo}
  alias InvestimentPlatform.Ticker

  @ttl :timer.hours(1)

  @spec get_max_quote(String.t(), String.t()) :: integer() | nil
  @decorate cacheable(cache: Cache, key: {:max_quote, ticker, start_date}, opts: [ttl: @ttl])
  def get_max_quote(ticker, start_date) when is_binary(ticker) and is_binary(start_date) do
    query =
      from t in Ticker,
        where: t.ticker == ^ticker,
        select: max(t.price)

    query = apply_optional_start_date_filter(query, start_date)

    Repo.one(query)
  end

  @spec get_max_daily_volume(String.t(), String.t()) :: integer() | nil
  @decorate cacheable(
              cache: Cache,
              key: {:max_daily_volume, ticker, start_date},
              opts: [ttl: @ttl]
            )
  def get_max_daily_volume(ticker, start_date) when is_binary(ticker) and is_binary(start_date) do
    query =
      from t in Ticker,
        where: t.ticker == ^ticker,
        group_by: t.date,
        select: %{amount: sum(t.amount)}

    query = apply_optional_start_date_filter(query, start_date)

    query =
      from t in subquery(query),
        select: max(t.amount)

    Repo.one(query)
  end

  defp apply_optional_start_date_filter(query, ""), do: query

  defp apply_optional_start_date_filter(query, start_date) when is_binary(start_date) do
    case Date.from_iso8601(start_date) do
      {:ok, _datetime} ->
        from q in query, where: q.date >= ^start_date

      {:error, _reason} ->
        query
    end
  end
end
