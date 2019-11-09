defmodule Docker.Repo.Migrations.ImproveStatusData do
  use Ecto.Migration

  def change do
    alter table(:containers) do
      add :up, :boolean, default: false
    end
  end
end
