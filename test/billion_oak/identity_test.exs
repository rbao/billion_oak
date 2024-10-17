defmodule BillionOak.IdentityTest do
  use BillionOak.DataCase
  import BillionOak.Factory
  alias BillionOak.Identity

  describe "organizations" do
    alias BillionOak.Identity.Organization
    @invalid_attrs %{name: nil}

    test "list_organizations/0 returns all organizations" do
      assert length(Identity.list_organizations()) == 1
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = insert(:organization)
      assert {:ok, %Organization{}} = Identity.get_organization(organization.id)
    end

    test "get_organization/1 returns error when organization not found" do
      assert {:error, :not_found} = Identity.get_organization("some id")
    end

    test "create_organization/1 with valid data creates a organization" do
      company = insert(:company)
      valid_attrs = params_for(:organization, company_id: company.id)

      assert {:ok, %Organization{} = organization} = Identity.create_organization(valid_attrs)
      assert organization.name == valid_attrs.name
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identity.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = insert(:organization)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Organization{} = organization} =
               Identity.update_organization(organization, update_attrs)

      assert organization.name == update_attrs.name
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = insert(:organization)

      assert {:error, %Ecto.Changeset{}} =
               Identity.update_organization(organization, @invalid_attrs)
    end

    test "delete_organization/1 deletes the organization" do
      organization = insert(:organization)
      assert {:ok, %Organization{}} = Identity.delete_organization(organization)
      assert {:error, :not_found} = Identity.get_organization(organization.id)
    end
  end

  describe "clients" do
    alias BillionOak.Identity.Client

    import BillionOak.IdentityFixtures

    @invalid_attrs %{name: nil, secret: nil, organization_id: nil}

    test "list_clients/0 returns all clients" do
      assert length(Identity.list_clients()) == 1
    end

    test "get_client!/1 returns the client with given id" do
      client = client_fixture()
      assert {:ok, _} = Identity.get_client(client.id)
    end

    test "create_client/1 with valid data creates a client" do
      valid_attrs = %{
        name: "some name",
        secret: "some secret",
        organization_id: "some organization_id"
      }

      assert {:ok, %Client{} = client} = Identity.create_client(valid_attrs)
      assert client.name == "some name"
      assert client.secret
      assert client.organization_id == "some organization_id"
    end

    test "create_client/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identity.create_client(@invalid_attrs)
    end

    test "update_client/2 with valid data updates the client" do
      client = client_fixture()

      update_attrs = %{
        name: "some updated name",
        secret: "some updated secret",
        organization_id: "some updated organization_id"
      }

      assert {:ok, %Client{} = client} = Identity.update_client(client, update_attrs)
      assert client.name == "some updated name"
      assert client.secret
      assert client.organization_id == "some updated organization_id"
    end

    test "update_client/2 with invalid data returns error changeset" do
      client = client_fixture()
      assert {:error, %Ecto.Changeset{}} = Identity.update_client(client, @invalid_attrs)
      assert {:ok, _} = Identity.get_client(client.id)
    end

    test "delete_client/1 deletes the client" do
      client = client_fixture()
      assert {:ok, %Client{}} = Identity.delete_client(client)
      assert {:error, :not_found} = Identity.get_client(client.id)
    end

    test "change_client/1 returns a client changeset" do
      client = client_fixture()
      assert %Ecto.Changeset{} = Identity.change_client(client)
    end
  end

  describe "users" do
    alias BillionOak.Identity.User

    import BillionOak.IdentityFixtures

    @invalid_attrs %{first_name: nil, last_name: nil, organization_id: nil, company_id: nil, company_account_id: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Identity.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Identity.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{first_name: "some first_name", last_name: "some last_name", organization_id: "some organization_id", company_id: "some company_id", company_account_id: "some company_account_id"}

      assert {:ok, %User{} = user} = Identity.create_user(valid_attrs)
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert user.organization_id == "some organization_id"
      assert user.company_id == "some company_id"
      assert user.company_account_id == "some company_account_id"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identity.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{first_name: "some updated first_name", last_name: "some updated last_name", organization_id: "some updated organization_id", company_id: "some updated company_id", company_account_id: "some updated company_account_id"}

      assert {:ok, %User{} = user} = Identity.update_user(user, update_attrs)
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      assert user.organization_id == "some updated organization_id"
      assert user.company_id == "some updated company_id"
      assert user.company_account_id == "some updated company_account_id"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Identity.update_user(user, @invalid_attrs)
      assert user == Identity.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Identity.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Identity.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Identity.change_user(user)
    end
  end
end
