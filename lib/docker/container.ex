defmodule Docker.Container do
  use Ecto.Schema

  schema "containers" do
    field :container_id, :string
    field :image, :string
    field :command, :string
    field :name, :string
    field :container_created_at, :string
    field :port, :string
    field :status, :string
  end

  def changeset(container, params \\ %{}) do
    permitted_params = [:container_id, :image, :command, :name, :container_created_at, :port, :status]
    container
    |> Ecto.Changeset.cast(params, permitted_params)
    |> Ecto.Changeset.validate_required(Enum.filter(permitted_params, &(&1 != :port)))
  end
end 
