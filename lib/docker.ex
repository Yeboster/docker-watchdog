defmodule Docker do
  @moduledoc """
  Module that interact with Docker with some commands and parses them into Map type
  """

  @doc """
  Calls all three scrape functions and compose a single list with all features
  """
  @spec compose_all_scrapes() :: [%{key: String.t()}]
  def compose_all_scrapes() do
    scrape_ps()
  end

  @doc """
  Scrape the docker ps row of a container with 7 values (including ports)
  """
  def scrape_ps(row) when is_list(row) and length(row) == 7 do
    container_keys = [:id, :image, :command, :created, :status, :ports, :names]

    lists_into_map(container_keys, row)
  end

  @doc """
  Scrape the docker ps row of a container with 6 values (EXCLUDING ports)
  """
  def scrape_ps(row) when is_list(row) and length(row) == 6 do
    container_keys = [:id, :image, :command, :created, :status, :names]

    lists_into_map(container_keys, row)
    |> Map.merge(%{port: ""})
  end

  @doc """
  Scrape the input as the docker ps command output
  """
  def scrape_ps(output) when is_bitstring(output) do
    str_not_empty? = fn str when is_bitstring(str) -> str != "" end

    lines =
      String.split(output, "\n")
      |> List.delete_at(0)
      |> Enum.filter(str_not_empty?)

    # Using stream since it's lazy
    matrix =
      Stream.map(lines, fn line ->
        String.split(line, "  ")
        |> Enum.filter(str_not_empty?)
      end)

    matrix
    |> Enum.map(fn row -> scrape_ps(row) end)
  end

  @doc """
  Scrape the docker ps command and return a Map type
  """
  @spec scrape_ps() :: [%{key: String.t()}]
  def scrape_ps() do
    {output, 0} = cmd_docker(["ps", "-a"])

    scrape_ps(output)
  end

  def scrape_stats() do
  end

  def scrape_ip_addr(container_id) do
  end

  @spec lists_into_map([String.t()], [String.t()]) :: [%{key: String.t()}]
  defp lists_into_map(keys, values) when is_list(keys) and is_list(values) do
    Stream.zip(keys, values)
    |> Enum.into(%{}, fn {key, value} -> {key, value} end)
  end

  defp cmd_docker(commands) when is_list(commands) do
    System.cmd("docker", commands)
  end
end
