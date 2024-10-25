defmodule BillionOak.IdentityTest do
  use BillionOak.DataCase
  import BillionOak.Factory

  alias BillionOak.Identity
  alias BillionOak.Identity.{Organization, Client, User, InvitationCode}

  test "all organizations can be retrieved at once" do
    assert {:ok, organizations} = Identity.list_organizations()
    assert length(organizations) == 1
  end

  describe "retrieving an organization" do
    test "returns the organization with the given handle if exists" do
      organization = insert(:organization)
      assert {:ok, %Organization{}} = Identity.get_organization(handle: organization.handle)
    end

    test "returns an error if no organization is found with the given handle" do
      assert {:error, :not_found} = Identity.get_organization(handle: "some handle")
    end
  end

  describe "creating an organization" do
    test "returns the created organization if the given input is valid" do
      input = params_for(:organization)

      assert {:ok, %Organization{} = organization} = Identity.create_organization(input)
      assert organization.name == input.name
    end

    test "returns an error if the given input is invalid" do
      assert {:error, %Ecto.Changeset{}} = Identity.create_organization(%{})
    end
  end

  describe "updating an organization" do
    test "returns the updated organization if the given input is valid" do
      organization = insert(:organization)
      input = %{name: "some updated name"}

      assert {:ok, %Organization{} = organization} =
               Identity.update_organization(organization, input)

      assert organization.name == input.name
    end

    test "returns an error if the given input is invalid" do
      organization = insert(:organization)

      assert {:error, %Ecto.Changeset{}} =
               Identity.update_organization(organization, %{name: nil})
    end
  end

  test "an organization can be deleted" do
    organization = insert(:organization)
    assert {:ok, %Organization{}} = Identity.delete_organization(organization)
    assert {:error, :not_found} = Identity.get_organization(handle: organization.handle)
  end

  test "all clients can be retrieved at once" do
    assert {:ok, clients} = Identity.list_clients()
    assert length(clients) == 1
  end

  describe "retrieving a client" do
    test "returns the client with the given id if exists" do
      client = insert(:client)
      assert {:ok, %Client{}} = Identity.get_client(client.id)
    end

    test "returns an error if no client is found with the given id" do
      assert {:error, :not_found} = Identity.get_client("456")
    end
  end

  describe "creating a client" do
    test "returns the created client if the given input is valid" do
      input = params_for(:client)
      assert {:ok, %Client{} = client} = Identity.create_client(input)
      assert client.name == input.name
    end

    test "returns an error if the given input is invalid" do
      assert {:error, %Ecto.Changeset{}} = Identity.create_client(%{})
    end
  end

  describe "updating a client" do
    test "returns the updated client if the given input is valid" do
      client = insert(:client)
      input = %{name: "some updated name"}

      assert {:ok, %Client{} = client} = Identity.update_client(client, input)
      assert client.name == input.name
    end

    test "returns an error if the given input is invalid" do
      client = insert(:client)
      assert {:error, %Ecto.Changeset{}} = Identity.update_client(client, %{name: nil})
    end
  end

  test "a client can be deleted" do
    client = insert(:client)
    assert {:ok, %Client{}} = Identity.delete_client(client)
    assert {:error, :not_found} = Identity.get_client(client.id)
  end

  describe "verifying a client with an id and secret" do
    test "returns the client if they match a client" do
      client = insert(:client)
      assert {:ok, %Client{}} = Identity.verify_client(client.id, client.secret)
    end

    test "returns an error if the client is not found" do
      assert {:error, :invalid} = Identity.verify_client("456", "some secret")
    end

    test "returns an error if the secret is incorrect" do
      client = insert(:client)
      assert {:error, :invalid} = Identity.verify_client(client.id, "some incorrect secret")
    end
  end

  test "all users can be retrieved at once" do
    insert(:user)

    assert {:ok, users} = Identity.list_users()
    assert length(users) == 1
  end

  describe "retrieving a user" do
    test "returns the user with the given id in the given organization if exists" do
      user = insert(:user)

      assert {:ok, %User{}} =
               Identity.get_user(id: user.id, organization_id: user.organization_id)
    end

    test "returns an error if no user is found matching the input" do
      assert {:error, :not_found} = Identity.get_user(id: "456", organization_id: "789")
    end
  end

  describe "creating a user" do
    test "returns the created user if the given input is valid" do
      input = params_for(:user)
      assert {:ok, %User{} = user} = Identity.create_user(input)
      assert user.first_name == input.first_name
    end

    test "returns an error if the given input is invalid" do
      assert {:error, %Ecto.Changeset{}} = Identity.create_user(%{})
    end
  end

  describe "updating a user" do
    test "returns the updated user if the given input is valid" do
      user = insert(:user)
      input = %{first_name: "some updated first name"}

      assert {:ok, %User{} = user} = Identity.update_user(user, input)
      assert user.first_name == input.first_name
    end

    test "returns an error if the given input is invalid" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Identity.update_user(user, %{role: nil})
    end
  end

  test "a user can be deleted" do
    user = insert(:user)
    assert {:ok, %User{}} = Identity.delete_user(user)
    assert {:error, :not_found} = Identity.get_user(id: user.id)
  end

  test "a user can be retrieved and if it doesn't exist be created at the same time" do
    identifier = %{wx_app_openid: "123"}
    data = %{organization_id: "test"}

    assert {:ok, %User{} = user} = Identity.get_or_create_user(identifier, data)

    assert user.wx_app_openid == "123"
    assert user.organization_id == "test"
  end

  test "all invitation codes can be retrieved at once" do
    insert(:invitation_code)

    assert {:ok, invitation_codes} = Identity.list_invitation_codes()
    assert length(invitation_codes) == 1
  end

  describe "retrieving an invitation code" do
    test "returns the invitation code with the given value if exists" do
      invitation_code = insert(:invitation_code)
      assert {:ok, %InvitationCode{}} = Identity.get_invitation_code(invitation_code.value)
    end

    test "returns an error if no invitation code is found with the given value" do
      assert {:error, :not_found} = Identity.get_invitation_code("some value")
    end
  end

  describe "creating an invitation code" do
    test "returns the created invitation code if the given input is valid" do
      company_account = insert(:company_account)

      input = %{
        organization_id: company_account.organization_id,
        invitee_company_account_rid: company_account.rid
      }

      assert {:ok, %InvitationCode{} = invitation_code} = Identity.create_invitation_code(input)
      assert invitation_code.value
      assert invitation_code.invitee_company_account_rid == input.invitee_company_account_rid
    end

    test "returns an error if the given input is invalid" do
      assert {:error, %Ecto.Changeset{}} = Identity.create_invitation_code(%{})
    end
  end

  test "invitation code can be deleted" do
    invitation_code = insert(:invitation_code)
    assert {:ok, %InvitationCode{}} = Identity.delete_invitation_code(invitation_code)
    assert {:error, :not_found} = Identity.get_invitation_code(invitation_code.value)
  end

  describe "guest signing up with an invitation code and a company account rid" do
    test "becomes a member by default if invitation code matches the company account rid" do
      guest = insert(:user, role: :guest)
      company_account = insert(:company_account, organization_id: guest.organization_id)

      invitation_code =
        insert(:invitation_code,
          organization_id: company_account.organization_id,
          invitee_company_account_rid: company_account.rid
        )

      input = %{company_account_rid: company_account.rid, invitation_code: invitation_code.value}

      assert {:ok, %User{} = user} = Identity.sign_up(guest.id, input)
      assert user.company_account_rid == company_account.rid
      assert user.role == :member
    end

    test "becomes an admin if the invitation code is for an admin and matches the company account rid" do
      guest = insert(:user, role: :guest)
      company_account = insert(:company_account, organization_id: guest.organization_id)

      invitation_code =
        insert(:invitation_code,
          organization_id: guest.organization_id,
          invitee_company_account_rid: company_account.rid,
          invitee_role: :admin
        )

      input = %{company_account_rid: company_account.rid, invitation_code: invitation_code.value}

      assert {:ok, %User{} = user} = Identity.sign_up(guest.id, input)
      assert user.company_account_rid == company_account.rid
      assert user.role == :admin
    end

    test "returns an error if the guest does not exist" do
      assert {:error, :not_found} =
               Identity.sign_up("invalid", %{
                 company_account_rid: "some rid",
                 invitation_code: "some code"
               })
    end

    test "returns an error if the invitation code is invalid" do
      guest = insert(:user, role: :guest)

      assert {:error, :invalid_invitation_code} =
               Identity.sign_up(guest.id, %{
                 company_account_rid: "some rid",
                 invitation_code: "some code"
               })
    end
  end
end
