defmodule MACD do
  @hist_diff 0.011

  def get_current(symbol, interval) do
    get_macd(symbol, interval) |> format_response() |> Enum.sort(& &1[:date] > &2[:date])
  end

  def find_crossovers(points, acc \\ [])
  def find_crossovers([_], acc), do: acc
  def find_crossovers([hd|tl = [hd2|_]], acc) do
    acc = 
      case %{date: date, value: %{macd_hist: macd_hist}} = hd do
        _ when macd_hist < @hist_diff and macd_hist > -@hist_diff ->
          acc ++ [{date, get_direction(hd, hd2)}]
        _ -> acc
      end
    tl |> find_crossovers(acc)
  end

  defp get_direction(%{value: %{macd: macd}}, %{value: %{macd: prev_macd}}) do
    cond do
      macd > prev_macd -> :up
      true -> :down
    end
  end

  defp get_macd(symbol, interval) do
    url = "http://www.alphavantage.co/query?function=MACD&symbol=#{symbol}&interval=#{interval}&series_type=close&apikey=#{System.get_env("AV_API_KEY")}"
    (HTTPoison.get!(url).body |> Poison.decode!())["Technical Analysis: MACD"]
  end

  defp format_response(macd_source) do
    macd_source |> Map.keys
    |> Enum.map(fn date -> 
      %{
        "MACD" => macd,
        "MACD_Hist" => macd_hist,
        "MACD_Signal" => macd_signal
      } = macd_source[date]

      %{date: date, value: %{
        macd: macd |> String.to_float,
        macd_hist: macd_hist |> String.to_float,
        macd_signal: macd_signal |> String.to_float
      }}
    end)
  end
end
