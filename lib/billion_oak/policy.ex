defmodule BillionOak.Policy do
  @admin_roles ["owner", "admin"]
  @dev_roles @admin_roles ++ ["developer"]

  @operator_roles @dev_roles ++ ["operator"]
  @guest_roles @operator_roles ++ ["guest"]

  def authorize(%{_role_: "sysdev"} = req, _), do: {:ok, req}
  def authorize(%{_role_: "system"} = req, _), do: {:ok, req}
  def authorize(%{_role_: "appdev"} = req, _), do: {:ok, req}
  def authorize(%{_client_: nil}, _), do: {:error, :access_denied}

  def authorize(%{_role_: role} = req, :get_company_account_excerpt) when role in @guest_roles,
    do: {:ok, req}

  def authorize(_, _), do: {:error, :access_denied}
end
