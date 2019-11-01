use Mix.Config

config :watchdog_bot, Docker.Repo,
  database: "watchdog_docker",
  username: "postgres",
  password: "postgres",
  hostname: "172.22.4.2",
  port: "5432"
