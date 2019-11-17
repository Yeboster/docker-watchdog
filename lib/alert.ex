defmodule Docker.Alert do
  import Docker.Alert.Utils

  defguard is_container_map(map) when is_map(map)

  def inform_of(map) when is_container_map(map) do
    message = """
    The container <b>#{map.name} #{if map.running, do: "is running", else: "is NOT running"}</b>.
    Useful information:
    - <b>id</b>: <code>#{map.container_id}</code>
    - <b>image</b>: #{map.image}
    - <b>command</b>: <code>#{map.command}</code>
    - <b>status</b>: <code>#{map.status}</code>
    """

    channel_id = Application.get_env(:watchdog_bot, :telegram_channel_id)

    send_html(channel_id, message)
  end
end
