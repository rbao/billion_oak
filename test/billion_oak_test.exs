defmodule BillionOakTest do
  use BillionOak.DataCase
  import Mox
  import BillionOak.Factory
  alias BillionOak.Request

  def anyone(attrs) do
    attrs = Enum.into(attrs, %{})
    Map.merge(%Request{}, attrs)
  end

  def anonymous(attrs, client) do
    anyone(attrs)
    |> Map.put(:client_id, client.id)
  end

  def user(attrs, client, user) do
    anyone(attrs)
    |> Map.put(:client_id, client.id)
    |> Map.put(:requester_id, user.id)
  end

  def sysops(attrs) do
    anyone(attrs)
    |> Map.put(:_role_, :sysops)
  end

  test "anyone can verify client" do
    client = insert(:client)
    data = %{client_id: client.id, client_secret: client.secret}
    req = anyone(%{data: data})

    result = BillionOak.verify_client(req)

    assert {:ok, %{data: client}} = result
    assert client.id == client.id
  end

  test "anonymous user can become guest" do
    client = insert(:client)
    data = %{wx_app_openid: "openid"}
    req = anonymous(%{data: data}, client)

    result = BillionOak.get_or_create_user(req)

    assert {:ok, %{data: user}} = result
    assert user.role == :guest
    assert user.wx_app_openid == "openid"
  end

  describe "guest" do
    test "can sign up to become a member by using their company account rid and a invitation code" do
      client = insert(:client)

      user =
        insert(:user,
          role: :guest,
          company_account_id: nil,
          organization_id: client.organization_id
        )

      company_account = insert(:company_account, organization_id: client.organization_id)

      invitation_code =
        insert(:invitation_code,
          organization_id: client.organization_id,
          invitee_company_account_rid: company_account.rid
        )

      data = %{
        company_account_rid: company_account.rid,
        invitation_code: invitation_code.value,
        first_name: "John",
        last_name: "Doe"
      }

      req = user(%{data: data}, client, user)

      result = BillionOak.sign_up(req)

      assert {:ok, %{data: user}} = result
      assert user.role == :member
      assert user.company_account_id == company_account.id
      assert user.first_name == data.first_name
      assert user.last_name == data.last_name
    end
  end

  describe "member" do
    test "can get their own user detail" do
      client = insert(:client)
      member = insert(:user, role: :member, organization_id: client.organization_id)
      identifier = %{id: member.id}
      req = user(%{identifier: identifier}, client, member)

      result = BillionOak.get_user(req)

      assert {:ok, %{data: user}} = result
      assert user.id == member.id
    end

    test "can get their own company account" do
      client = insert(:client)
      company_account = insert(:company_account, organization_id: client.organization_id)

      member =
        insert(:user,
          role: :member,
          organization_id: client.organization_id,
          company_account_id: company_account.id
        )

      identifier = %{ids: [company_account.id]}
      req = user(%{identifier: identifier}, client, member)

      result = BillionOak.list_company_accounts(req)

      assert {:ok, %{data: [member_company_account]}} = result
      assert member_company_account.id == company_account.id
    end
  end

  describe "system operator" do
    test "can create a company" do
      data = params_for(:company)
      req = sysops(%{data: data})

      result = BillionOak.create_company(req)

      assert {:ok, %{data: company}} = result
      assert company.handle == data.handle
    end

    test "can get an organization's detail by handle" do
      req = sysops(%{identifier: %{handle: "happyteam"}})

      result = BillionOak.get_organization(req)

      assert {:ok, %{data: organization}} = result
      assert organization.handle == "happyteam"
    end

    test "can create an invitation code" do
      company_account = insert(:company_account)

      data = %{
        organization_id: company_account.organization_id,
        invitee_company_account_rid: company_account.rid
      }

      req = sysops(%{data: data})

      result = BillionOak.create_invitation_code(req)

      assert {:ok, %{data: code}} = result
      assert String.length(code.value) == 6
    end

    test "can ingest external data" do
      identifier = %{handle: "happyteam"}
      req = sysops(%{identifier: identifier})

      expect(BillionOak.FilestoreMock, :list_files, fn _, _ ->
        {:ok, [%{key: "file_key"}]}
      end)

      expect(BillionOak.FilestoreMock, :stream_file, fn "file_key" ->
        {:ok, File.stream!("test/support/fixtures/mannatech.mtku")}
      end)

      result = BillionOak.ingest_external_data(req)

      assert {:ok, %{data: data}} = result
      assert [{"file_key", {:ok, 20}}] = data
    end
  end
end
