defmodule BillionOak.Identity.UserTest do
  use BillionOak.UnitCase, async: true
  import BillionOak.Factory
  alias BillionOak.Identity.User

  describe "when creating user" do
    test "default role is guest" do
      assert %User{}.role == :guest
    end

    test "role is not required to be given" do
      params = params_for(:user)
      changeset = User.changeset(%User{}, params)
      assert changeset.valid?
    end

    test "wechat identifier and organization is saved" do
      params = %{wx_app_openid: "openid", organization_id: "org_id"}
      changeset = User.changeset(%User{}, params)

      assert changeset.valid?
      assert changeset.changes.wx_app_openid == "openid"
      assert changeset.changes.organization_id == "org_id"
    end
  end
end
