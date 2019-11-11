defmodule Docker.Alert do
  import Docker.Alert.Utils

  defguard is_container_map(map) when is_map(map)

  def inform_of(map) when is_container_map(map) do
    message = """
    The container *#{map.name}* *#{if map.running, do: "is running", else: "is NOT running"}*.
    Useful information:
    - *id*: #{map.container_id}
    - *image*: #{map.image}
    - *command*: `#{map.command}`
    - *status*: `#{map.status}`
    """

    send_markdown(Application.get_env(:watchdog_bot, :telegram_channel_id), message)
  end
end
