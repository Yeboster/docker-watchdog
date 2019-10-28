defmodule Docker.Runner do
  def insert_docker_ps() do
    Docker.Scrape.docker_ps()
    |> Enum.map(fn scraped ->
      Docker.Container.from_map(scraped)
      |> Docker.Repo.insert!()

      IO.puts("Data inserted correctly!")
    end)
  end
end
