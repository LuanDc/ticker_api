defmodule TickerApi.Repo.Migrations.CreateTickersTable do
  use Ecto.Migration

  def change do
    create table(:tickers) do
      add :date, :date
      add :ticker, :string
      add :price, :float
      add :amount, :integer
      add :closing_time, :string
      add :event_id, :string
    end

    create index(:tickers, [:ticker, :date])
    create unique_index(:tickers, [:event_id])
  end
end
