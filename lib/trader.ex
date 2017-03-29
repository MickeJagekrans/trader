defmodule Trader do
  def calculate(symbol, interval) do
    macds = MACD.get_current(symbol, interval)
    rsis = RSI.get_current(symbol, interval)
    stock = Stock.get_current(symbol, interval)

    macds
    |> MACD.find_crossovers()
    |> filter_mismatch(rsis)
    |> Enum.map(fn {date, dir}-> {date, dir, stock[date <> ":00"]} end)
  end

  defp filter_mismatch(crossovers, rsis) do
    crossovers
    |> Enum.filter(fn {date, dir}->
      rsi = rsis |> Enum.find(fn {rsi_date, _}-> date == rsi_date end) |> elem(1)
      case dir do
        :up -> rsi < 45
        :down -> rsi > 55
      end
    end)
  end
end
