defmodule CSwap.MockStore do
  use Agent
  require Logger

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    Logger.debug("Get key: #{key}")
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  def put(key, mock_fn) when is_function(mock_fn) do
    Logger.debug("Put key: #{key}, mock: #{inspect(mock_fn)}")
    Agent.update(__MODULE__, &Map.put(&1, key, mock_fn))
  end

  def reset() do
    Agent.update(__MODULE__, fn _ -> %{} end)
  end
end
