defmodule Docker.Repo.Migrations.AddTimestampsToContainers do
  use Ecto.Migration

  def change do
    alter table(:containers) do
      remove :inserted_at

      timestamps()
    end
  end
end
