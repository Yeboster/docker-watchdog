
import Config

config :watchdog_bot, Docker.Repo,
  database: "${PG_DB}",
  username: "${PG_USER}",
  password: "${PG_PASS}",
  hostname: "${PG_HOST}",
  port: 5432
