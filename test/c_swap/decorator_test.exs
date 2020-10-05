defmodule CSwap.DecoratorTest do
  use ExUnit.Case

  setup do
    :seq_trace.set_token(:label, nil)
    CSwap.reset()
    :ok
  end

  test "mocks function in same process" do
    assert_raise CSwap.NotMockedError, fn -> TestModule.exec1() end
    ref = make_ref()
    :ok = CSwap.mock(TestModule, :exec1, fn -> ref end)
    assert TestModule.exec1() == ref

    ref = make_ref()
    assert_raise CSwap.NotMockedError, fn -> TestModule.exec2(1, 2) end
    :ok = CSwap.mock(TestModule, :exec2, fn _, _ -> ref end)
    assert TestModule.exec2(1, 2) == ref

    assert TestModule.exec3(1, 2, 3) == :original
  end

  test "mocks function in different process" do
    ref = make_ref()

    {:ok, pid} = TestProcess.start_link([])

    :ok = CSwap.mock(TestProcess, :handle_decorator, fn state -> {:reply, ref, state} end)
    assert TestProcess.test_decorator(pid) == ref
  end
end
