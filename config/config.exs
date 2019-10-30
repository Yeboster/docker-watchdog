import Config

config :watchdog_bot, telegram_token: "${TG_TOK}"

config :watchdog_bot, ecto_repos: [Docker.Repo]

import_config "#{Mix.env()}.exs"
