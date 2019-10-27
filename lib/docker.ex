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
    String.split(output, "\n")
    |> List.delete_at(0)
    |> Enum.filter(&str_not_empty?/1)
    |> Stream.map(fn line ->
      String.split(line, "  ")
      |> Enum.filter(&str_not_empty?/1)
    end)
    |> Enum.map(&scrape_ps/1)
  end

  @doc """
  Scrape the docker ps command and return a Map type
  """
  @spec scrape_ps() :: [%{key: String.t()}]
  def scrape_ps() do
    {output, 0} = cmd_docker(["ps", "-a"])

    scrape_ps(output)
  end

  @doc """
  Scrape docker stat row into a map type
  """
  def scrape_stats(values) when is_list(values) and length(values) == 8 do
    stats_keys = [:id, :name, :cpu, :memory, :memory_percentage, :net_io, :block_io, :pids]

    lists_into_map(stats_keys, values)
  end

  @doc """
  Scrape docker stat command output into a list containing map type
  """
  def scrape_stats(output) when is_bitstring(output) do
    String.split(output, "\n")
    |> List.delete_at(0)
    |> Stream.filter(&str_not_empty?/1)
    |> Stream.map(fn line ->
      String.split(line, "  ")
      |> Enum.filter(&str_not_empty?/1)
    end)
    |> Enum.map(&scrape_stats/1)
  end

  @doc """
  Scrape docker stat command calling it into the shell
  """
  @spec scrape_stats() :: [%{key: String.t()}]
  def scrape_stats() do
    {output, 0} = cmd_docker(["stats", "--no-stream"])

    scrape_stats(output)
  end

  def scrape_ip_addr(network_json) when is_map(network_json) do
    Map.to_list(network_json)
    |> Enum.map(fn {key, value} -> %{key => "#{value["IPAddress"]}/#{value["IPPrefixLen"]}"} end)
  end

  def scrape_ip_addr(container_id) when is_bitstring(container_id) do
    sanitized = String.replace(container_id, Regex.compile!("[^a-z|A-Z|_]"), "")

    {output, 0} = cmd_docker(["inspect", "-f", "'{{json .NetworkSettings.Networks}}'", sanitized])

    Jason.decode!(output)
  end

  @doc """
  Scrape each conainer id and return its Ip address and subnet mask
  """
  @spec scrape_ip_addr([String.t()]) :: [%{key: String.t()}]
  def scrape_ip_addr(container_ids) when is_list(container_ids) do
    Enum.map(container_ids, fn id -> scrape_ip_addr(id) end)
  end

  @spec lists_into_map([String.t()], [String.t()]) :: [%{key: String.t()}]
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
