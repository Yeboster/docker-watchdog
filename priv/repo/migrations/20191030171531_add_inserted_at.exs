defmodule Docker.Repo.Migrations.AddInsertedAt do
  use Ecto.Migration

  def change do
    alter table(:cotainers) do
      add :inserted_at, :utc_datetime
    end

  end
end
