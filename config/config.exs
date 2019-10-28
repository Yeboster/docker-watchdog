use Mix.Config

config :watchdog_bot, ecto_repos: [Database.Repo]

config :watchdog_bot, Database.Repo,
  database: "watchdog_docker",
  username: "postgres",
  password: "", # TODO: Load password from env
  hostname: "localhost",
  port: "5432"
