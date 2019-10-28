use Mix.Config

config :watchdog_bot, ecto_repos: [Docker.Repo]

maybe_token =
  case System.fetch_env("TG_TOK") do
    {:ok, token} -> token
    :error -> ""
  end
  
config :watchdog_bot, telegram_token: maybe_token

import_config "#{Mix.env()}.exs"
