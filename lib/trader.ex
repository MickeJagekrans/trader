defmodule Trader do
  def calculate do
    macds = MACD.get_current()
    stochs = STOCH.get_current()
    rsis = RSI.get_current()

    { macds, stochs, rsis } |> IO.inspect
  end
end

defmodule MACD do
  @url "http://www.alphavantage.co/query?function=MACD&symbol=MSFT&interval=15min&series_type=close&apikey="

  def get_current do
    get_macd() |> format_response() |> Enum.sort(& &1[:date] > &2[:date])
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

defmodule STOCH do
  @url "http://www.alphavantage.co/query?function=STOCH&symbol=MSFT&interval=15min&slowkmatype=1&slowdmatype=1&apikey="

  def get_current do
    get_stoch() |> format_response() |> Enum.sort(& &1[:date] > &2[:date])
  end

  def get_stoch do
    %{body: body} = HTTPoison.get!(@url <> System.get_env("AV_API_KEY"))
    ((body |> Poison.decode!())["Technical Analysis: STOCH"])
  end

  def format_response(stoch_source) do
    stoch_source |> Map.keys
    |> Enum.map(fn date ->
      %{
        "SlowD" => slow_d,
        "SlowK" => slow_k
      } = stoch_source[date]

      %{date: date, value: %{
        slow_d: slow_d |> String.to_float,
        slow_k: slow_k |> String.to_float
      }}
    end)
  end
end

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
