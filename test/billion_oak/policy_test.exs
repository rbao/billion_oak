defmodule BillionOak.PolicyTest do
  use BillionOak.UnitCase, async: true
  alias BillionOak.Identity.{Client, User}
  alias BillionOak.{Request, Policy}

  def req(attrs \\ []) do
    base = %Request{_client_: %Client{}, _organization_id_: "org_id", _role_: "guest"}
    attrs = Enum.into(attrs, %{})
    Map.merge(base, attrs)
  end

  describe "create_invitation_code" do
    test "scope/2" do
      req = req()
      assert Policy.scope(req, :create_invitation_code) == req

      user = %User{id: "user_id"}
      req = req(requester_id: "user_id", _requester_: user, _role_: "member")
      req = Policy.scope(req, :create_invitation_code)
      assert req.data[:inviter_id] == "user_id"
      assert req.data[:inviter] == user
    end

    test "authorize/2" do
      req = req()
      assert {:error, :access_denied} == Policy.authorize(req, :create_invitation_code)

      req = req(requester_id: "user_id", _role_: "member")
      assert {:error, :access_denied} == Policy.authorize(req, :create_invitation_code)

      req = req(requester_id: "user_id", _role_: "member", data: %{inviter_id: "user_id"})
      assert {:ok, _} = Policy.authorize(req, :create_invitation_code)
    end
  end
end
