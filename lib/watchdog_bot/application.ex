defmodule WatchdogBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: WatchdogBot.Worker.start_link(arg)
      # {WatchdogBot.Worker, arg}
      # This will setup the Registry.ExGram
      ExGram,
      # Setup Telegram bot
      {WatchdogBot.Bot, [method: :polling, token: Application.get_env(:ex_gram, :token)]},
      # Setup Docker database
      {Docker.Repo, []},
      ###
      # Runner to insert docker ps data into db
      ###
      # Every minute
      %{
        id: "docker_ps",
        start: {SchedEx, :run_every, [Docker.Runner, :insert_docker_ps, [], "*/1 * * * *"]}
      },
      # Every minute
      %{
        id: "docker_monitor_status",
        start: {SchedEx, :run_every, [Docker.Runner, :monitor_container_status, [], "*/1 * * * *"]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WatchdogBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
