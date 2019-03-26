defmodule Metex.Worker do
  def ping do
    receive do
      _ ->
        IO.puts "pong"
    end
    ping
  end

  def pong do
    receive do
      _ ->
        IO.puts "ping"
    end
    pong
  end

  def loop do
    receive do
      {sender_pid, location} ->
        send(sender_pid, {:ok, temperature_of(location)})
      _ ->
        IO.puts "don't know how to process this message"
    end
    loop
  end

  def temperature_of(location) do
    result = location
             |> url_for()
             |> HTTPoison.get()
             |> parse_response()

    case result do
      {:ok, temp} ->
        "#{location}: #{temp} °C"
      :error ->
        "#{location} not found"
    end
  end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey()}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode() |> compute_temperature()
  end

  defp parse_response(_) do
    :error
  end

  defp compute_temperature({:ok, json}) do
    temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
    {:ok, temp}
  end

  defp compute_temperature({:error, _}) do
    :error
  end

  defp apikey do
    "686e8cca60baeb479503d5d87cdfbbf0"
  end
end
