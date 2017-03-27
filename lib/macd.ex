defmodule MACD do
  @url "http://www.alphavantage.co/query?function=MACD&symbol=ATVI&interval=15min&series_type=close&apikey="

  def get_current do
    get_macd() |> format_response() |> Enum.sort(& &1[:date] > &2[:date])
  end

  def find_crossovers(points, acc \\ [])
  def find_crossovers([_], acc), do: acc
  def find_crossovers([hd|tl = [hd2|_]], acc) do
    acc = 
      case %{value: %{macd_hist: macd_hist}} = hd do
        _ when macd_hist < 0.005 and macd_hist > -0.005 ->
          acc ++ [hd |> Map.put(:value, get_direction(hd, hd2))]
        _ -> acc
      end
    tl |> find_crossovers(acc)
  end

  defp get_direction(%{value: value = %{macd: macd}}, %{value: %{macd: prev_macd}}) do
    direction =
      case macd > prev_macd do
        true -> :up
        _ -> :down
      end

    value |> Map.put(:direction, direction)
  end

  defp get_macd do
    %{body: body} = HTTPoison.get!(@url <> System.get_env("AV_API_KEY"))
    (body |> Poison.decode!())["Technical Analysis: MACD"]
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