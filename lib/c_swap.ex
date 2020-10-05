defmodule CSwap do
  alias CSwap.MockStore

  @global_prefix :global

  defmodule NotMockedError do
    defexception [:message]
  end

  def mockable(module, fun, args) do
    prefix = get_label() || @global_prefix
    key = build_key(prefix, module, fun, length(args))
    mock = MockStore.get(key)

    if mock do
      apply(mock, args)
    else
      raise NotMockedError,
        message:
          "Could not find a mocked implementation for #{module}: #{fun}/#{length(args)} with args #{
            inspect(args)
          }"
    end
  end

  def mock(module, fun, mock_fn, mode \\ :local) when is_function(mock_fn) do
    prefix =
      if mode == :local do
        set_label()
      else
        @global_prefix
      end

    arity = :erlang.fun_info(mock_fn)[:arity]
    key = build_key(prefix, module, fun, arity)

    MockStore.put(key, mock_fn)
  end

  def reset(), do: MockStore.reset()

  defp set_label() do
    case get_label() do
      nil ->
        label = UUID.uuid4()
        :seq_trace.set_token(:label, label)
        label

      label ->
        label
    end
  end

  defp get_label() do
    case :seq_trace.get_token() do
      {_, label, _, _, _} ->
        label

      [] ->
        nil
    end
  end

  defp build_key(prefix, module, fun, arity), do: "#{prefix}:#{module}:#{fun}:#{arity}"
end
