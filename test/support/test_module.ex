defmodule TestModule do
  use CSwap.Decorator
  alias CSwap

  def mocked1(), do: CSwap.mockable(__MODULE__, :mocked1, [])
  def mocked2(_, _), do: CSwap.mockable(__MODULE__, :mocked2, [1, 2])

  @decorate mockable()
  def exec1(), do: :original

  @decorate mockable()
  def exec2(_arg1, _arg2), do: :original

  # Not mockable
  def exec3(_arg1, _arg2, _arg3 \\ []), do: :original
end
