defmodule Docker.Alert do

  defguard is_container_map(map) when is_map(map)

  def inform_of(map) when is_container_map(map) do
    # TODO: alert telegram channel
  end
  
end
