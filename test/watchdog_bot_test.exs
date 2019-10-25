defmodule WatchdogBotTest do
  use ExUnit.Case
  doctest WatchdogBot

  test "greets the world" do
    assert WatchdogBot.hello() == :world
  end
end
