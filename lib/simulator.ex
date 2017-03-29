defmodule Simulator do
  @exit_low -6

  def run(symbols, interval) do
    symbols
    |> Enum.map(& Task.async(fn -> run_one(&1, interval) end))
    |> Enum.map(fn task-> Task.await(task, 10000) end)
    |> IO.inspect |> Enum.sum
  end
  
  def run_one(symbol, interval) do
    Trader.calculate(symbol, interval)
    |> Enum.reverse
    |> make_actions()
    #|> IO.inspect
    |> calculate_profit()
  end

  defp make_actions(_points, prev \\ nil, acc \\ [])
  defp make_actions([], _, acc), do: acc
  defp make_actions([{_, :up, _}|tl], prev = {_, :up, _}, acc), do: make_actions(tl, prev, acc)
  defp make_actions([{_, :down, _}|tl], prev = {_, :down, _}, acc), do: make_actions(tl, prev, acc)
  defp make_actions([curr = {_, :down, curr_value}|tl], prev = {_, :up, buy_value}, acc) do
    case sell?(curr_value, buy_value) do
      true -> make_actions(tl, curr, acc ++ [{buy_value, curr_value}])
      _ -> make_actions(tl, prev, acc)
    end
  end
  defp make_actions([curr = {_, dir, _}|tl], prev, acc) do
    cond do
      dir == :up -> make_actions(tl, curr, acc)
      true -> make_actions(tl, prev, acc)
    end
  end
  defp make_actions([curr|tl], nil, acc), do: make_actions(tl, curr, acc)

  defp sell?(curr_value, buy_value) do
    curr_value - buy_value >= 0.05 * buy_value || curr_value - buy_value <= @exit_low
  end

  defp calculate_profit(actions) do
    actions |> Enum.reduce(0, fn {prev_value, value}, acc-> acc + value - prev_value end)
  end
end
