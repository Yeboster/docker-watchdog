defmodule Docker.Repo.Migrations.ImproveStatusData do
  use Ecto.Migration

  def change do
    alter table(:containers) do
      add :running, :boolean, default: false
    end
  end
end
