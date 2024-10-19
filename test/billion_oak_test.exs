defmodule BillionOakTest do
  use BillionOak.DataCase
  import BillionOak.Factory
  alias BillionOak.Identity.Client
  alias BillionOak.Request

  def req(attrs \\ []) do
    base = %Request{_client_: %Client{}, _organization_id_: "org_id", _role_: "guest"}
    attrs = Enum.into(attrs, %{})
    Map.merge(base, attrs)
  end

  def sysops(attrs \\ []) do
    attrs = Enum.into(attrs, %{})
    Map.merge(%Request{_role_: "sysops"}, attrs)
  end

  describe "get_organization/1" do
    test "sysops" do
      result =
        %{identifier: %{handle: "happyteam"}}
        |> sysops()
        |> BillionOak.get_organization()

      assert {:ok, %{data: organization}} = result
      assert organization.handle == "happyteam"
    end
  end

  describe "create_invitation_code/1" do
    test "sysops" do
      {:ok, %{data: organization}} =
        %{identifier: %{handle: "happyteam"}}
        |> sysops()
        |> BillionOak.get_organization()

      company_account =
        insert(:company_account,
          organization_id: organization.id,
          company_id: organization.company_id
        )

      data = %{organization_id: organization.id, invitee_company_account_rid: company_account.rid}

      {:ok, %{data: code}} =
        %{data: data}
        |> sysops()
        |> BillionOak.create_invitation_code()

      assert String.length(code.value) == 6
    end
  end
end
