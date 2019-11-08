use Mix.Config

config :ex_gram, token: System.get_env("TG_TOK")
config :watchdog_bot, telegram_channel_id: -1001275098496

config :watchdog_bot, ecto_repos: [Docker.Repo]

if Mix.env() == :dev do
  import_config "dev.exs"
end
