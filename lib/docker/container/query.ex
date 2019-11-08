defmodule Docker.Container.Query do
  import Ecto.Query, only: [from: 2, limit: 2]

  @doc """
  Returns all containers with bad status
  """
  def bad_status_containers() do
    # Fetch data limit 2 from each container
    from(c in Docker.Container,
      select: c.container_id,
      group_by: c.container_id,
      where: fragment("lower(?)", c.status) |> like("exit%")
    )
    |> Docker.Repo.all()
  end

  @doc """
  QUERY All tuples specified container
  """
  def ordered_from_id(id) when is_bitstring(id) do
    from(c in Docker.Container,
      where: c.container_id == ^id,
      order_by: [desc: c.inserted_at]
    )
  end

  @doc """
  QUERY Limit returns
  """
  def with_limit(query, num) when is_integer(num) do
    query |> limit(^num)
  end

  # TODO: Change is_map to is_container_map
  @doc """
  Set to true the alert flag on container map
  """
  def alerted!(map) when is_map(map) do
    %{map | alerted: true}
    |> Docker.Container.changeset()
    |> Docker.Repo.insert!()
  end
end
