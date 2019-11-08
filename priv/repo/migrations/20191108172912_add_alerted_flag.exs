defmodule Docker.Repo.Migrations.AddAlertedFlag do
  use Ecto.Migration

  def change do
    alter table(:containers) do
      add :alerted, :boolean
    end

  end
end
