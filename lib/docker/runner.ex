defmodule Docker.Runner do
  require Logger
  alias Docker.Container.Query, as: ContainerQuery
  alias Docker.Repo, as: Repo

  def insert_docker_ps() do
    Docker.Scrape.docker_ps()
    |> Enum.map(fn scraped ->
      Docker.Container.from_map(scraped)
      |> Repo.insert!()

      # Change with Logging
      IO.puts("Data inserted correctly!")
    end)
  end

  def monitor_container_status() do
    ContainerQuery.bad_status_containers()
    |> Enum.each(fn id ->
      status =
        ContainerQuery.ordered_from_id(id)
        |> ContainerQuery.with_limit(2)
        |> Repo.all()

      if Enum.count(status) == 2 do
        # Compare the container status
        latest = List.first(status)
        older = List.last(status)

        if latest.status != older.status && latest.alerted != true do
          IO.puts("Alert id: #{latest.container_id}")

          # TODO: manage and log if the alert has not been sent!
          Docker.Alert.inform_of(latest)
          ContainerQuery.alerted!(latest)
        end
      end
    end)
  end
end
