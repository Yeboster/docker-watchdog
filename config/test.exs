use Mix.Config

config :watchdog_bot, Docker.Repo,
  database: "watchdog_docker",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: "5432"
