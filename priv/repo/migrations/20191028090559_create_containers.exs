defmodule Docker.Repo.Migrations.CreateContainers do
  use Ecto.Migration

  def change do
    create table(:containers) do
      add :container_id, :string
      add :image, :string
      add :command, :string
      add :name, :string
      add :container_created_at, :string
      add :port, :string
      add :status, :string
    end
  end
end
