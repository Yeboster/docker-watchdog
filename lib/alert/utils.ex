defmodule Docker.Alert.Utils do

  defguard are_bitstrings(str1, str2) when is_bitstring(str1) and is_bitstring(str2)

  def with_bold(str, bold) when are_bitstrings(str, bold) do
    str <> " *#{bold}* "
  end
  
  def with_text(str1, str2) when are_bitstrings(str1, str2) do
    str1 <> " " <> str2
  end

  def send_markdown(channel, message) when is_integer(channel) or is_bitstring(channel) and is_bitstring(message) do
    ExGram.send_message(channel, message, [parse_mode: "Markdown"])
  end

end
