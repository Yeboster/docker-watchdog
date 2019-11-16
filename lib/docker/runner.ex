defmodule Docker.Runner do
  require Logger
  alias Docker.Container.Query, as: ContainerQuery
  alias Docker.Repo, as: Repo

  def insert_docker_ps() do
    Docker.Scrape.docker_ps()
    |> Enum.each(fn scraped ->
      Docker.Container.from_map(scraped)
      |> Repo.insert!()

      Logger.info("Data inserted correctly!")
    end)
  end

  def monitor_container_status() do
    ContainerQuery.bad_status_containers()
    |> Enum.each(fn id ->
      Logger.info("Checking status of container (id: #{id})")

      status =
        ContainerQuery.ordered_from_id(id)
        |> ContainerQuery.with_limit(2)
        |> Repo.all()

      if Enum.count(status) == 2 do
        # Compare the container status
        latest = List.first(status)
        older = List.last(status)

        if latest.running != older.running && latest.alerted != true do
          Logger.warn(
            "Alerting to channel container (id: #{latest.container_id}, name: #{latest.name})"
          )

          # TODO: manage and log if the alert has not been sent!
          Docker.Alert.inform_of(latest)
          ContainerQuery.alerted!(latest)
        end
      end
    end)
  end
end
