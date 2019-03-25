defmodule Metex do
  @moduledoc """
  Documentation for Metex.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Metex.hello()
      :world

  """
  def hello do
    :world
  end

  def temperatures_of(cities) do
    coordinator_pid =
      spawn(Metex.Coordinator, :loop, [[], Enum.count(cities)])

    apply_to_city = fn city ->
      worker_pid = spawn(Metex.Worker, :loop, [])
      send(worker_pid, {coordinator_pid, city})
    end

    cities |> Enum.each(apply_to_city)
  end
end
