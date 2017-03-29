defmodule TraderTest do
  use ExUnit.Case
  doctest Trader

  test "see gain/loss" do
    points = Trader.calculate("MSFT", "15min")

    IO.inspect(points)
  end
end
