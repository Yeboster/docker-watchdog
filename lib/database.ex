defmodule Database.Repo do
  use Ecto.Repo,
    otp_app: :watchdog_bot,
    adapter: Ecto.Adapters.Postgres
end
