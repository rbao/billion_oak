defmodule BillionOak.IdentityTest do
  use BillionOak.DataCase

  alias BillionOak.Identity

  describe "clients" do
    alias BillionOak.Identity.Client

    import BillionOak.IdentityFixtures

    @invalid_attrs %{name: nil, secret: nil, organization_id: nil}

    test "list_clients/0 returns all clients" do
      assert length(Identity.list_clients()) == 1
    end

    test "get_client!/1 returns the client with given id" do
      client = client_fixture()
      assert Identity.get_client!(client.id) == client
    end

    test "create_client/1 with valid data creates a client" do
      valid_attrs = %{name: "some name", secret: "some secret", organization_id: "some organization_id"}

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
      update_attrs = %{name: "some updated name", secret: "some updated secret", organization_id: "some updated organization_id"}

      assert {:ok, %Client{} = client} = Identity.update_client(client, update_attrs)
      assert client.name == "some updated name"
      assert client.secret
      assert client.organization_id == "some updated organization_id"
    end

    test "update_client/2 with invalid data returns error changeset" do
      client = client_fixture()
      assert {:error, %Ecto.Changeset{}} = Identity.update_client(client, @invalid_attrs)
      assert client == Identity.get_client!(client.id)
    end

    test "delete_client/1 deletes the client" do
      client = client_fixture()
      assert {:ok, %Client{}} = Identity.delete_client(client)
      assert_raise Ecto.NoResultsError, fn -> Identity.get_client!(client.id) end
    end

    test "change_client/1 returns a client changeset" do
      client = client_fixture()
      assert %Ecto.Changeset{} = Identity.change_client(client)
    end
  end
end
