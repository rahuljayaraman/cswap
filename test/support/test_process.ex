defmodule TestProcess do
  use GenServer
  use CSwap.Decorator

  def init(_opts) do
    {:ok, []}
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [])
  end

  def test_decorator(pid) do
    GenServer.call(pid, :decorator)
  end

  def test_mocked(pid) do
    GenServer.call(pid, :mocked)
  end

  # Callbacks
  #
  def handle_call(:mocked, from, state) do
    handle_mocked(from, state)
  end

  def handle_call(:decorator, _from, state) do
    handle_decorator(state)
  end

  @decorate mockable()
  defp handle_decorator(state) do
    {:reply, :original, state}
  end

  defp handle_mocked(from, state) do
    CSwap.mockable(__MODULE__, :handle_call, [:mocked, from, state])
  end
end
