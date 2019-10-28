use Mix.Config

config :watchdog_bot, ecto_repos: [Docker.Repo]

config :watchdog_bot, Docker.Repo,
  database: System.fetch_env!("PG_DB"),
  username: System.fetch_env!("PG_USER"),
  password: System.fetch_env!("PG_PASS"),
  hostname: System.fetch_env!("PG_HOST"),
  port: System.fetch_env!("PG_PORT")
