defmodule RSI do
  def get_current(symbol, interval) do
    get_rsi(symbol, interval) |> format_response() |> Enum.sort(& elem(&1, 0) > elem(&2, 0))
  end

  def get_rsi(symbol, interval) do
    url = "http://www.alphavantage.co/query?function=RSI&symbol=#{symbol}&interval=#{interval}&time_period=14&series_type=close&apikey=#{System.get_env("AV_API_KEY")}"
    %{body: body} = HTTPoison.get!(url)
    ((body |> Poison.decode!())["Technical Analysis: RSI"])
  end

  defp format_response(rsi_source) do
    rsi_source |> Map.keys
    |> Enum.map(fn date ->
      %{ "RSI" => rsi } = rsi_source[date]
      {date, rsi |> String.to_float }
    end)
  end
end
