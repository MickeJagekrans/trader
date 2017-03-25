defmodule Trader do
  @url "http://www.alphavantage.co/query?function=MACD&symbol=MSFT&interval=30min&series_type=close&apikey="

  def calculate do
    formatted_macds = get_macd() |> format_response()
  end

  defp get_macd do
    %{body: body} = HTTPoison.get!(@url <> System.get_env("AV_API_KEY"))
    (body |> Poison.decode!())["Technical Analysis: MACD"]
  end

  defp format_response(macd_source) do
    macd_source |> Map.keys
    |> Enum.map(fn date -> 
      macd_source[date] |> IO.inspect
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
