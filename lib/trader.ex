defmodule Trader do
  def calculate do
    macds = MACD.get_current()
    rsis = RSI.get_current()

    macds |> MACD.find_crossovers()
  end
end