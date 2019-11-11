defmodule WatchdogBot.Bot do
  @bot :watchdog_bot

  import WatchdogBot
  alias Docker.Container.Query, as: ContainerQuery

  use ExGram.Bot,
    name: @bot

  middleware(ExGram.Middleware.IgnoreUsername)

  def bot(), do: @bot

  def handle({command, str, msg}, context) do
    if allowed?(msg) do
      authenticated({command, str, msg}, context)
    else
      answer(context, "Sir #{current_name(msg)}, you are not allowed to use this bot.")
    end
  end

  def authenticated({:command, "start", _msg}, context) do
    answer(context, "Conquer the world!")
  end

  def authenticated({:command, "containers", _msg}, context) do
    keyboard =
      Docker.Container.Query.unique_containers()
      |> Docker.Repo.all()
      |> Enum.map(fn [id, _, name, _] ->
        [
          %ExGram.Model.KeyboardButton{
            text: "#{name}->#{id}"
          }
        ]
      end)

    answer(context, "What is the container you want information of ?",
      reply_markup: %ExGram.Model.ReplyKeyboardMarkup{
        resize_keyboard: true,
        keyboard: keyboard
      }
    )
  end

  def authenticated({:text, message, _}, context) when is_bitstring(message) do
    commands = String.split(message, "->")

    if Enum.count(commands) == 2 do
      id = List.last(commands)

      container =
        ContainerQuery.last_from_id(id)
        |> Docker.Repo.one()

      message = """
      Useful information about the selected container:
      - id: *#{container.container_id}*
      - name: *#{container.name}*
      - image: *#{container.image}*
      - last status: _#{container.status}_
      """

      answer(context, message, parse_mode: "Markdown")
    end
  end
end
