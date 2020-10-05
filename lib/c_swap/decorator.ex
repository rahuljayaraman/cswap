defmodule CSwap.Decorator do
  use Decorator.Define, mockable: 0

  def mockable(body, %{name: fun, module: module, args: args}) do
    quote location: :keep,
          bind_quoted: [body: body, fun: fun, module: module, args: args] do
      if Mix.env() == :test do
        CSwap.mockable(module, fun, args)
      else
        body
      end
    end
  end
end
