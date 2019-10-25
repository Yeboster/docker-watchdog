use Mix.Config

config :watchdog_bot, ecto_repos: [Main.Repo]

config :watchdog_bot, Main.Repo,
  database: "watchdog_docker",
  username: "postgres",
  password: "", # TODO: Load password from env
  hostname: "localhost",
  port: "5432"
