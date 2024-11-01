defmodule BillionOak.PolicyTest do
  use BillionOak.UnitCase, async: true
  import BillionOak.Factory
  alias BillionOak.Identity.Client
  alias BillionOak.{Request, Policy}

  def req(attrs \\ []) do
    organization_id =
      if attrs[:_requester_], do: attrs[:_requester_].organization_id, else: "org_id"

    base = %Request{_client_: %Client{}, organization_id: organization_id, _role_: :guest}
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

    test "the invitee role will be removed from the request if given" do
      user = build(:user, role: :member)
      data = %{invitee_role: :admin}
      req = req(_requester_: user, _role_: :member, requester_id: user.id, data: data)

      req = Policy.scope(req, :create_invitation_code)

      assert req.data[:inviter_id] == user.id
      assert req.data[:inviter] == user
      refute req.data[:invitee_role]
    end

    test "the request is authorized only if the inviter is themself and invitee role is not given" do
      req = req(requester_id: "user_id", _role_: :member, data: %{inviter_id: "user_id"})
      assert {:ok, ^req} = Policy.authorize(req, :create_invitation_code)
    end

    test "the request is denied if the inviter is not set" do
      req = req(requester_id: "user_id", _role_: :member)
      assert {:error, :access_denied} == Policy.authorize(req, :create_invitation_code)
    end

    test "the request is denied if the invitee role is given" do
      req =
        req(
          requester_id: "user_id",
          _role_: :member,
          data: %{inviter_id: "user_id", invitee_role: :admin}
        )

      assert {:error, :access_denied} == Policy.authorize(req, :create_invitation_code)
    end
  end

  describe "when guest is getting a user's detail" do
    test "the request is authorized if the user is themself" do
      guest = build(:user, role: :guest)
      identifier = %{id: guest.id}

      req =
        req(_requester_: guest, _role_: :guest, requester_id: guest.id, identifier: identifier)

      assert {:ok, ^req} = Policy.authorize(req, :get_user)
    end

    test "the request is denied if the user is not themself" do
      guest = build(:user, role: :guest)
      identifier = %{id: "other_user_id"}

      req =
        req(_requester_: guest, _role_: :guest, requester_id: guest.id, identifier: identifier)

      assert {:error, :access_denied} == Policy.authorize(req, :get_user)
    end
  end

  describe "when member is getting a list of company accounts" do
    test "the request is authorized if the user is associated with those company accounts" do
      member = build(:user, role: :member, company_account_id: "company_account_id")

      req =
        req(
          _requester_: member,
          _role_: :member,
          requester_id: member.id,
          identifier: %{ids: ["company_account_id"]}
        )

      assert {:ok, ^req} = Policy.authorize(req, :list_company_accounts)
    end

    test "the request is denied if the user is not associated with any one of those company accounts" do
      member = build(:user, role: :member)

      req =
        req(
          _requester_: member,
          _role_: :member,
          requester_id: member.id,
          identifier: %{ids: ["nop"]}
        )

      assert {:error, :access_denied} == Policy.authorize(req, :list_company_accounts)
    end
  end

  describe "when admin is reserving a file location" do
    test "the owner will always be set to themself in the request" do
      user = build(:user, role: :admin)
      req = req(_requester_: user, _role_: :admin, requester_id: user.id)

      req = Policy.scope(req, :reserve_file_location)

      assert req.data[:owner_id] == user.id
      assert req.data[:owner] == user
    end

    test "the organization will always be set to the organization of themself" do
      user = build(:user, role: :admin)
      req = req(_requester_: user, _role_: :admin, requester_id: user.id)

      req = Policy.scope(req, :reserve_file_location)

      assert req.data[:organization_id] == user.organization_id
    end

    test "the request is authorized only if the owner is themself and organization is the organization of the owner" do
      user = build(:user, role: :admin)

      req =
        req(
          _role_: :admin,
          organization_id: user.organization_id,
          requester_id: user.id,
          data: %{owner_id: user.id, organization_id: user.organization_id}
        )

      assert {:ok, ^req} = Policy.authorize(req, :reserve_file_location)
    end
  end

  describe "when admin is registering a file" do
    test "the owner will always be set to themself in the request" do
      user = build(:user, role: :admin)
      req = req(_requester_: user, _role_: :admin, requester_id: user.id)

      req = Policy.scope(req, :register_file)

      assert req.data[:owner_id] == user.id
      assert req.data[:owner] == user
    end

    test "the organization will always be set to the organization of themself" do
      user = build(:user, role: :admin)
      req = req(_requester_: user, _role_: :admin, requester_id: user.id)

      req = Policy.scope(req, :register_file)

      assert req.data[:organization_id] == user.organization_id
    end

    test "the request is authorized only if the owner is themself and organization is the organization of the owner" do
      user = build(:user, role: :admin)

      req =
        req(
          _role_: :admin,
          organization_id: user.organization_id,
          requester_id: user.id,
          data: %{owner_id: user.id, organization_id: user.organization_id}
        )

      assert {:ok, ^req} = Policy.authorize(req, :register_file)
    end
  end

  describe "when admin is creating an audio" do
    test "the organization will always be set to the organization of themself" do
      user = build(:user, role: :admin)
      req = req(_requester_: user, _role_: :admin, requester_id: user.id)

      req = Policy.scope(req, :create_audio)

      assert req.data[:organization_id] == user.organization_id
    end

    test "the request is authorized only if the organization is the organization of the requester" do
      user = build(:user, role: :admin)

      req =
        req(
          _role_: :admin,
          organization_id: user.organization_id,
          requester_id: user.id,
          data: %{organization_id: user.organization_id}
        )

      assert {:ok, ^req} = Policy.authorize(req, :create_audio)
    end
  end
end
