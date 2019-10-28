defmodule Scrape do
  @moduledoc """
  Module that interact with Docker with some commands and parses them into Map type
  """

  @doc """
  Calls all three scrape functions and compose a single list with all features
  """
  @spec compose_all() :: [%{key: String.t()}]
  def compose_all() do
    containers = docker_ps()
    stats = docker_stats()

    Enum.map(containers, fn container ->
      update_stats = fn container ->
        container_stats = Enum.find(stats, fn %{"id" => id} -> id == container["id"] end)
        %{container | "statistics" => container_stats}
      end

      update_network = fn container ->
        network_info = docker_container_ip(container["id"])
        %{container | "networks" => network_info}
      end

      is_running? = container["status"] |> String.downcase() |> String.contains?("up")

      if is_running? do
        # Adding statistics and network information
        Map.merge(container, %{"statistics" => %{}, "networks" => []})
        |> update_stats.()
        |> update_network.()
      else
        container
      end
    end)
  end

  @doc """
  Scrape the docker ps row of a container with 7 values (including ports)
  """
  def docker_ps(row) when is_list(row) and length(row) == 7 do
    container_keys = ["id", "image", "command", "created", "status", "ports", "names"]

    lists_into_map(container_keys, row)
  end

  @doc """
  Scrape the docker ps row of a container with 6 values (EXCLUDING ports)
  """
  def docker_ps(row) when is_list(row) and length(row) == 6 do
    container_keys = ["id", "image", "command", "created", "status", "names"]

    lists_into_map(container_keys, row)
    |> Map.merge(%{"port" => ""})
  end

  @doc """
  Scrape the input as the docker ps command output
  """
  def docker_ps(output) when is_bitstring(output) do
    String.split(output, "\n")
    |> List.delete_at(0)
    |> Enum.filter(&str_not_empty?/1)
    |> Stream.map(fn line ->
      String.split(line, "  ")
      |> Enum.filter(&str_not_empty?/1)
    end)
    |> Enum.map(&docker_ps/1)
  end

  @doc """
  Scrape the docker ps command and return a Map type
  """
  @spec docker_ps() :: [%{key: String.t()}]
  def docker_ps() do
    case cmd_docker(["ps", "-a"]) do
      {output, 0} ->
        docker_ps(output)

      {error, status_code} ->
        [%{"error" => error, "status_code" => status_code}]
    end
  end

  @doc """
  Scrape docker stat row into a map type
  """
  def docker_stats(values) when is_list(values) and length(values) == 8 do
    stats_keys = [
      "id",
      "name",
      "cpu",
      "memory",
      "memory_percentage",
      "net_io",
      "block_io",
      "pids"
    ]

    lists_into_map(stats_keys, values)
  end

  @doc """
  Scrape docker stat command output into a list containing map type
  """
  def docker_stats(output) when is_bitstring(output) do
    String.split(output, "\n")
    |> List.delete_at(0)
    |> Stream.filter(&str_not_empty?/1)
    |> Stream.map(fn line ->
      String.split(line, "  ")
      |> Enum.filter(&str_not_empty?/1)
    end)
    |> Enum.map(&docker_stats/1)
  end

  @doc """
  Scrape docker stat command calling it into the shell
  """
  @spec docker_stats() :: [%{key: String.t()}]
  def docker_stats() do
    case cmd_docker(["stats", "--no-stream"]) do
      {output, 0} ->
        docker_stats(output)

      {error, status_code} ->
        [%{"error" => error, "status_code" => status_code}]
    end
  end

  def docker_container_ip(network_json) when is_map(network_json) do
    Map.to_list(network_json)
    |> Enum.map(fn {key, value} -> %{key => "#{value["IPAddress"]}/#{value["IPPrefixLen"]}"} end)
  end

  def docker_container_ip(container_id) when is_bitstring(container_id) do
    sanitized = String.replace(container_id, Regex.compile!("[^a-z|A-Z|0-9|_|-]"), "")

    case cmd_docker(["inspect", "-f", "'{{json .NetworkSettings.Networks}}'", sanitized]) do
      {output, 0} ->
        output
        |> String.replace(Regex.compile!("('|\\n)"), "")
        |> Jason.decode!()
        |> docker_container_ip

      {error, status_code} ->
        %{"error" => error, "status_code" => status_code}
    end
  end

  @doc """
  Scrape each conainer id and return its Ip address and subnet mask
  """
  @spec docker_container_ip([String.t()]) :: [%{key: String.t()}]
  def docker_container_ip(container_ids) when is_list(container_ids) do
    Enum.map(container_ids, fn id -> docker_container_ip(id) end)
  end

  defp lists_into_map(keys, values) when is_list(keys) and is_list(values) do
    Stream.zip(keys, values)
    |> Enum.into(%{}, fn {key, value} -> {key, String.trim(value)} end)
  end

  defp str_not_empty?(str) when is_bitstring(str) do
    str != ""
  end

  defp cmd_docker(commands) when is_list(commands) do
    System.cmd("docker", commands)
  end
end
