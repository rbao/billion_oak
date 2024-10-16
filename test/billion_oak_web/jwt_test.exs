defmodule BillionOakWeb.JWTTest do
  use BillionOak.DataCase
  alias BillionOakWeb.JWT

  describe "clients" do
    @tag :focus
    test "it works" do
      {:ok, token, _claims} = JWT.generate_and_sign()
      assert is_binary(token)

      IO.inspect JWT.verify_and_validate(token)
    end
  end
end
