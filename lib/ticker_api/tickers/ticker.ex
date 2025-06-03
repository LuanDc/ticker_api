defmodule InvestimentPlatform.Ticker do
  @moduledoc false
  use Ecto.Schema

  schema "tickers" do
    field :date, :date
    field :ticker, :string
    field :price, :float
    field :amount, :integer
    field :closing_time, :string
    field :event_id, :string
  end
end
