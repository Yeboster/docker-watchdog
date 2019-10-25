defmodule WatchdogBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    token = '827073286:AAG3xN8YwfnVodARREgoSzepJ1nAufrND4M' # TODO: Remove and use secrets or env
    children = [
      # Starts a worker by calling: WatchdogBot.Worker.start_link(arg)
      # {WatchdogBot.Worker, arg}
      ExGram, # This will setup the Registry.ExGram
      {WatchdogBot.Bot, [method: :polling, token: token]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WatchdogBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
