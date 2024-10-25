defmodule BillionOak.PolicyTest do
  use BillionOak.UnitCase, async: true
  import BillionOak.Factory
  alias BillionOak.Identity.Client
  alias BillionOak.{Request, Policy}

  def req(attrs \\ []) do
    base = %Request{_client_: %Client{}, _organization_id_: "org_id", _role_: :guest}
    attrs = Enum.into(attrs, %{})
    Map.merge(base, attrs)
  end

  describe "when member is creating invitation code" do
    test "the inviter will always be set to themself in the request" do
      user = build(:user, role: :member)
      req = req(requester_id: user.id, _requester_: user, _role_: :member)

      req = Policy.scope(req, :create_invitation_code)

      assert req.data[:inviter_id] == user.id
      assert req.data[:inviter] == user
    end

    test "the request is authorized only if the inviter is themself" do
      req = req(requester_id: "user_id", _role_: :member, data: %{inviter_id: "user_id"})
      assert {:ok, ^req} = Policy.authorize(req, :create_invitation_code)
    end

    test "the request is denied if the inviter is not set" do
      req = req(requester_id: "user_id", _role_: :member)
      assert {:error, :access_denied} == Policy.authorize(req, :create_invitation_code)
    end
  end
end
