use Mix.Config

config :watchdog_bot, Docker.Repo,
  database: "watchdog_docker",
  username: "postgres",
  password: "postgres",
  hostname: "127.0.0.1",
  port: 5432
