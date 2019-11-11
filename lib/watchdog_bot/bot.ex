defmodule WatchdogBot.Bot do
  @bot :watchdog_bot

  use ExGram.Bot,
    name: @bot

  middleware(ExGram.Middleware.IgnoreUsername)

  def bot(), do: @bot

  def handle({command, str, msg}, context) do
    if allowed?(msg) do
      authenticated({command, str, msg}, context)
    else
      answer(context, "Sir #{msg[:from][:first_name]}, you are not allowed to use this bot.")
    end
  end

  def allowed?(msg) do
    ids_allowed = [32_234_185]
    current_id = msg[:from][:id]

    Enum.any?(ids_allowed, &(&1 == current_id))
  end

  def authenticated({:command, "start", _msg}, context) do
    answer(context, "Conquer the world!")
  end

  def authenticated({:command, "containers", msg}, context) do
    keyboard =
      Docker.Container.Query.unique_containers()
      |> Docker.Repo.all()
      |> Enum.map(fn [id, _, name, _] ->
        [
          %ExGram.Model.KeyboardButton{
            text: "#{name}(#{id})"
          }
        ]
      end)

    ExGram.send_message(msg[:from][:id], "What is the container you want ?",
      reply_markup: %ExGram.Model.ReplyKeyboardMarkup{
        resize_keyboard: true,
        keyboard: keyboard
      }
    )
  end
end
