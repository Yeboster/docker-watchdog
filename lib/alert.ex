defmodule Docker.Alert do
  import Docker.Alert.Utils

  defguard is_container_map(map) when is_map(map)

  def inform_of(map) when is_container_map(map) do
    message =
      "The container named"
      |> with_bold(map.name)
      |> with_text("exited with")
      |> with_bold(map.status)
      |> with_text("status")

    send_markdown(Application.get_env(:watchdog_bot, :telegram_channel_id), message)
  end
end
