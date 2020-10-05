# CSwap

Mocking library for elixir

- Supports concurrent mocking across process boundaries using [:seq_trace](https://erlang.org/doc/man/seq_trace.html)
- Supports a decorator to swap code for test builds, using [arjan/decorator](https://github.com/arjan/decorator)

## Usage

Mark code as `mockable` using the decorator.

```module.ex
defmodule Module do
  use CSwap.Decorator

  @decorate mockable()
  def exec(), do: :original

  # Not mockable
  def exec2(), do: :original
end
```

Use `CSwap.mock(module, function_name, mock_fn)` to mock

```module_test.exs
defmodule ModuleTest do
  use ExUnit.Case

  test "mocks" do
    assert_raise CSwap.NotMockedError, fn -> Module.exec() end
    ref = make_ref()
    :ok = CSwap.mock(Module, :exec, fn -> ref end)
    assert Module.exec() == ref
  end
end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `cswap` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cswap, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/cswap](https://hexdocs.pm/cswap).
