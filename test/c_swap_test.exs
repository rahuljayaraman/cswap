defmodule CSwapTest do
  use ExUnit.Case

  doctest CSwap

  setup do
    :seq_trace.set_token(:label, nil)
    CSwap.reset()
    :ok
  end

  test "mocks function in same process" do
    assert_raise CSwap.NotMockedError, fn -> TestModule.mocked1() end
    ref = make_ref()
    :ok = CSwap.mock(TestModule, :mocked1, fn -> ref end)
    assert TestModule.mocked1() == ref

    assert_raise CSwap.NotMockedError, fn -> TestModule.mocked2(1, 2) end
    ref = make_ref()
    :ok = CSwap.mock(TestModule, :mocked2, fn _, _ -> ref end)
    assert TestModule.mocked2(3, 2) == ref
  end

  test "global mocks work" do
    # NOTE: not sure how to test this. any spawn seems to set token for spawing
    # process as well
    ref = make_ref()

    Task.async(fn ->
      :ok = CSwap.mock(TestModule, :mocked1, fn -> ref end, :global)
    end)
    |> Task.await()

    assert TestModule.mocked1() == ref
  end

  test "global mocks do not override local mocks" do
    ref = make_ref()
    :ok = CSwap.mock(TestModule, :mocked1, fn -> ref end)
    assert TestModule.mocked1() == ref

    :ok = CSwap.mock(TestModule, :mocked1, fn -> :global_mock end, :global)

    assert TestModule.mocked1() == ref
  end

  test "mocks function in different process" do
    ref = make_ref()

    {:ok, pid} = TestProcess.start_link([])

    :ok = CSwap.mock(TestProcess, :handle_call, fn _, _, state -> {:reply, ref, state} end)
    assert TestProcess.test_mocked(pid) == ref
  end
end
