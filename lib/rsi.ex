defmodule RSI do
  @url "http://www.alphavantage.co/query?function=RSI&symbol=MSFT&interval=15min&time_period=10&series_type=close&apikey="

  def get_current do
    get_rsi() |> format_response() |> Enum.sort(& &1[:date] > &2[:date])
  end

  def get_rsi do
    %{body: body} = HTTPoison.get!(@url <> System.get_env("AV_API_KEY"))
    ((body |> Poison.decode!())["Technical Analysis: RSI"])
  end

  def format_response(rsi_source) do
    rsi_source |> Map.keys
    |> Enum.map(fn date ->
      %{ "RSI" => rsi } = rsi_source[date]
      %{date: date, value: %{ rsi: rsi |> String.to_float }}
    end)
  end
end