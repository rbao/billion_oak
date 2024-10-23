defmodule BillionOak.Identity.UserTest do
  use BillionOak.UnitCase, async: true
  import BillionOak.Factory
  alias BillionOak.Identity.User

  describe "when updating user attributes" do
    test "role is not required to be given" do
      params = params_for(:user)
      changeset = User.changeset(%User{}, params)
      assert changeset.valid?
    end
  end
end
