defmodule BillionOak.Policy do
  alias BillionOak.Request
  @admin_roles [:owner, :admin]
  @dev_roles @admin_roles ++ [:developer]

  @operator_roles @dev_roles ++ [:operator]
  @member_roles @operator_roles ++ [:member]
  @guest_roles @member_roles ++ [:guest]
  @anonymous_roles @guest_roles ++ [:anonymous]

  def scope_authorize(req, api) do
    req
    |> scope(api)
    |> authorize(api)
  end

  def scope(%{_role_: role, _organization_id_: organization_id} = req, :get_or_create_user)
      when role in @anonymous_roles do
    Request.put(req, :identifier, :organization_id, organization_id)
  end

  def scope(
        %{_role_: role, _organization_id_: organization_id} = req,
        :get_company_account_excerpt
      )
      when role in @guest_roles do
    Request.put(req, :identifier, :organization_id, organization_id)
  end

  def scope(%{_role_: role} = req, :create_invitation_code) when role in @member_roles do
    req
    |> Request.put(:data, :inviter_id, req.requester_id)
    |> Request.put(:data, :inviter, req._requester_)
    |> Request.delete(:data, :invitee_role)
  end

  def scope(req, _), do: req

  def authorize(%{_role_: :sysdev} = req, _), do: {:ok, req}
  def authorize(%{_role_: :system} = req, _), do: {:ok, req}
  def authorize(%{_role_: :appdev} = req, _), do: {:ok, req}
  def authorize(%{_role_: :sysops} = req, _), do: {:ok, req}
  def authorize(%{_role_: nil}, _), do: {:error, :access_denied}
  def authorize(%{_client_: nil}, _), do: {:error, :access_denied}
  def authorize(%{_organization_id_: nil}, _), do: {:error, :access_denied}

  def authorize(%{_role_: role, _organization_id_: organization_id} = req, :get_or_create_user)
      when role in @anonymous_roles do
    if req.identifier[:organization_id] == organization_id do
      {:ok, req}
    else
      {:error, :access_denied}
    end
  end

  def authorize(%{requester_id: nil}, _), do: {:error, :access_denied}

  def authorize(%{_role_: role, _organization_id_: nil} = req, :get_company_account_excerpt)
      when role in @guest_roles do
    {:ok, req}
  end

  def authorize(
        %{_role_: role, _organization_id_: org_id} = req,
        :get_company_account_excerpt
      )
      when role in @guest_roles do
    if req.identifier[:organization_id] == org_id do
      {:ok, req}
    else
      {:error, :access_denied}
    end
  end

  def authorize(%{_role_: role} = req, :create_invitation_code)
      when role in @member_roles do
    if req.data[:inviter_id] == req.requester_id && !req.data[:invitee_role] do
      {:ok, req}
    else
      {:error, :access_denied}
    end
  end

  def authorize(%{_role_: role} = req, :sign_up) when role in @guest_roles do
    {:ok, req}
  end

  def authorize(%{_role_: role} = req, :get_user) when role in @guest_roles do
    if req.identifier[:id] == req.requester_id do
      {:ok, req}
    else
      {:error, :access_denied}
    end
  end

  def authorize(%{_role_: role, _requester_: requester} = req, :list_company_accounts)
      when role in @member_roles do
    if req.identifier[:ids] == [requester.company_account_id] do
      {:ok, req}
    else
      {:error, :access_denied}
    end
  end

  def authorize(_, _), do: {:error, :access_denied}
end
