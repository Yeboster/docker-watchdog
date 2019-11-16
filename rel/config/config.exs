use Mix.Config

config :ex_gram, token: System.get_env("TG_TOK")
config :watchdog_bot, telegram_channel_id: -1001275098496

config :watchdog_bot, ecto_repos: [Docker.Repo]

config :watchdog_bot, Docker.Repo,
  database: System.get_env("PG_DB"),
  username: System.get_env("PG_USER"),
  password: System.get_env("PG_PASS"),
  hostname: System.get_env("PG_HOST"),
  port: 5432

config :logger, :console,
  level: :info,
  format: "{\"timestamp\":\"$time\", \"level\":\"$metadata[$level]\", \"message\":\"$message\"}"
