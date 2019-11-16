defmodule Docker.Container do
  use Ecto.Schema

  schema "containers" do
    field(:container_id, :string)
    field(:image, :string)
    field(:command, :string)
    field(:name, :string)
    field(:container_created_at, :string)
    field(:port, :string)
    field(:running, :boolean)
    field(:status, :string)
    field(:alerted, :boolean)
    timestamps()
  end

  def changeset(container, params \\ %{}) do
    permitted_params = [
      :container_id,
      :image,
      :command,
      :name,
      :container_created_at,
      :port,
      :running,
      :status,
      :alerted
    ]

    container
    |> Ecto.Changeset.cast(params, permitted_params)
    |> Ecto.Changeset.validate_required(
      Enum.filter(permitted_params, fn param when is_atom(param) ->
        param != :port and param != :alerted
      end)
    )
  end

  def from_map(map) when is_map(map) do
    container_opts = %{
      container_id: map["id"],
      image: map["image"],
      command: map["command"],
      name: map["names"],
      container_created_at: map["created"],
      port: map["port"],
      running: map["running"],
      status: map["status"],
    }

    Docker.Container.changeset(%Docker.Container{}, container_opts)
  end
end
