defmodule BillionOak.Devop do
  alias BillionOak.Request

  def ht_seed() do
    {:ok, %{data: mannatech}} =
      BillionOak.create_company(%Request{
        _role_: :sysops,
        data: %{handle: "mannatech", name: "Mannatech"}
      })

    {:ok, %{data: happyteam}} =
      BillionOak.create_organization(%Request{
        _role_: :sysops,
        data: %{
          company_id: mannatech.id,
          handle: "happyteam",
          name: "Happy Team",
          root_company_account_rid: "1168402"
        }
      })

    {:ok, _} =
      BillionOak.create_client(%Request{
        _role_: :sysops,
        data: %{
          name: "WeChat Mini Program",
          organization_id: happyteam.id,
          wx_app_id: System.get_env("HT_WX_APP_ID"),
          wx_app_secret: System.get_env("HT_WX_APP_SECRET")
        }
      })
  end

  def ht_ingest() do
    %Request{_role_: :sysops, identifier: %{handle: "happyteam"}}
    |> BillionOak.ingest_external_data()
  end

  def ht_invite(company_account_rid, role) do
    req = %Request{_role_: :sysops, identifier: %{handle: "happyteam"}}
    {:ok, %{data: organization}} = BillionOak.get_organization(req)

    req = %Request{
      _role_: :sysops,
      data: %{
        organization_id: organization.id,
        invitee_company_account_rid: company_account_rid,
        invitee_role: String.to_atom(role)
      }
    }

    result = BillionOak.create_invitation_code(req)

    case result do
      {:ok, %{data: invitation_code}} ->
        {:ok, invitation_code.value}

      {:error, changeset} ->
        changeset.errors
    end
  end

  def all_clients() do
    BillionOak.Identity.list_clients()
  end
end
