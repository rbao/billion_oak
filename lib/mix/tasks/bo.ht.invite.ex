defmodule Mix.Tasks.Bo.Ht.Invite do
  use Mix.Task
  alias BillionOak.Request

  @shortdoc "Create a invitation code for happy team associate"
  @requirements ["app.start"]
  @impl Mix.Task
  def run([company_account_rid, role]) do
    req = %Request{_role_: :sysops, identifier: %{handle: "happyteam"}}
    {:ok, %{data: organization}} = BillionOak.get_organization(req)

    req = %Request{
      _role_: :sysops,
      data: %{
        organization_id: organization.id,
        invitee_company_account_rid: company_account_rid,
        role: String.to_atom(role)
      }
    }

    result = BillionOak.create_invitation_code(req)

    case result do
      {:ok, %{data: invitation_code}} -> IO.inspect(invitation_code.value)
      {:error, changeset} -> IO.inspect(changeset.errors)
    end
  end
end
