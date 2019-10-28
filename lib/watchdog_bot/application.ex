defmodule WatchdogBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # TODO: Remove and use secrets or env
    token = '827073286:AAG3xN8YwfnVodARREgoSzepJ1nAufrND4M'

    children = [
      # Starts a worker by calling: WatchdogBot.Worker.start_link(arg)
      # {WatchdogBot.Worker, arg}
      # This will setup the Registry.ExGram
      # ExGram,
      # Setup Telegram bot
      # {WatchdogBot.Bot, [method: :polling, token: token]},
      # Setup Docker database
      {Docker.Repo, []},
      # Runner to insert docker ps data into db
      %{
        id: "docker_ps",
        start: {SchedEx, :run_every, [Docker.Runner, :insert_docker_ps, [], "*/1 * * * *"]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WatchdogBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
