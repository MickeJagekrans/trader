defmodule Stock do
  def get_current(symbol, interval) do
    get_intraday(symbol, interval) |> format_response
  end

  defp get_intraday(symbol, interval) do
    url = "http://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=#{symbol}&interval=#{interval}&outputsize=full&apikey=#{System.get_env("AV_API_KEY")}"
    (HTTPoison.get!(url).body |> Poison.decode!())["Time Series (#{interval})"]
  end

  defp format_response(points) do
    points |> Map.keys |> Enum.reduce(%{}, fn date, acc->
      %{"4. close" => close} = points[date]
      Map.put(acc, date, close |> String.to_float)
    end)
  end
end
