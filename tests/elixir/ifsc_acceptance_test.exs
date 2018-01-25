defmodule IFSCAcceptanceTest do
  use ExUnit.Case
  alias Razorpay.IFSC

  describe "acceptance" do
    tests = Poison.decode!(File.read!("tests/validator_asserts.json"))

    Enum.map(tests, fn({name, cases}) ->
      cases = Macro.escape(cases)
      test name do
        Enum.map(unquote(Macro.expand(cases, __MODULE__)), fn({ifsc, valid}) ->
          if valid do
            assert {:ok, %IFSC{}} = IFSC.validate(ifsc)
          else
            assert {:error, _reason} = IFSC.validate(ifsc)
          end
        end)
      end
    end)
  end
end
