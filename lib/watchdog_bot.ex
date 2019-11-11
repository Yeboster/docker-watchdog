defmodule WatchdogBot do
  @moduledoc """
  Documentation for WatchdogBot.
  """

  @doc """
  Hello world.

  ## Examples

      iex> WatchdogBot.hello()
      :world

  """
  def allowed?(msg) when is_map(msg) do
    ids_allowed = [32_234_185, 160_690_758]
    current_id = msg[:from][:id]

    Enum.any?(ids_allowed, &(&1 == current_id))
  end

  def current_id(msg) when is_map(msg) do
    msg[:from][:id]
  end

  def current_name(msg) when is_map(msg) do
    msg[:from][:first_name]
  end
end
