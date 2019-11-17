defmodule Docker.Alert.Utils do
  require Logger

  defguard are_bitstrings(str1, str2) when is_bitstring(str1) and is_bitstring(str2)

  defguard valid_send_arguments(channel, message)
           when is_integer(channel) or (is_bitstring(channel) and is_bitstring(message))

  def with_bold(str, bold) when are_bitstrings(str, bold) do
    str <> " *#{bold}* "
  end

  def with_text(str1, str2) when are_bitstrings(str1, str2) do
    str1 <> " " <> str2
  end

  def send_markdown(message, channel \\ channel_id())
      when valid_send_arguments(channel, message) do
    ExGram.send_message(channel, message, parse_mode: "Markdown")
    |> handle_error()
  end

  def send_html(message, channel \\ channel_id()) when valid_send_arguments(channel, message) do
    ExGram.send_message(channel, message, parse_mode: "HTML")
    |> handle_error()
  end

  def handle_error(message_response) when is_tuple(message_response) do
    case message_response do
      {:ok, _} ->
        nil

      {:error, error} ->
        case Jason.decode(error["message"]) do
          {:ok, error} ->
            send_markdown(
              channel_id(),
              "An error happened while trying to send a message: #{error}"
            )

          {:error, _} ->
            Logger.error(inspect(error))

            send_markdown(
              channel_id(),
              "There has been an error but cannot parse correctly the response, check logs."
            )
        end
    end
  end

  defp channel_id() do
    Application.get_env(:watchdog_bot, :telegram_channel_id)
  end
end
