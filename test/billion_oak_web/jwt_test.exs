defmodule BillionOakWeb.JWTTest do
  use BillionOak.DataCase
  alias BillionOakWeb.JWT

  describe "clients" do
    @tag :focus
    test "it works" do
      {:ok, token, _claims} = JWT.generate_and_sign(%{aud: "test"})
      assert is_binary(token)
    end
  end
end
