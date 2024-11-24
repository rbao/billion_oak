defmodule BillionOak.Policy do
  use OK.Pipe
  alias BillionOak.Request
  @admin [:owner, :admin]
  @dev @admin ++ [:developer]

  @operator @dev ++ [:operator]
  @member @operator ++ [:member]
  @guest @member ++ [:guest]
  @anonymous @guest ++ [:anonymous]

  def scope_authorize(req, api) do
    req
    |> scope(api)
    |> authorize(api)
  end

  def scope(%{_role_: role} = req, :get_or_create_user) when role in @anonymous do
    put_organization_id(req, :identifier)
  end

  def scope(%{_role_: role} = req, :get_company_account_excerpt) when role in @guest do
    put_organization_id(req, :identifier)
  end

  def scope(%{_role_: role} = req, :list_company_accounts) when role in @member do
    req
    |> put_organization_id(:filter)
    |> Request.add_filter(:id, req._requester_.company_account_id)
  end

  def scope(%{_role_: role} = req, :create_invitation_code) when role in @admin do
    req
    |> put_organization_id(:data)
    |> Request.put(:data, :inviter_id, req.requester_id)
    |> Request.put(:data, :inviter, req._requester_)
    |> Request.delete(:data, :invitee_role)
  end

  def scope(%{_role_: role} = req, :sign_up) when role in @guest do
    req
    |> Request.put(:identifier, :id, req.requester_id)
  end

  def scope(%{_role_: role} = req, :get_sharer) when role in @guest do
    req
    |> put_organization_id(:identifier)
  end

  def scope(%{_role_: role} = req, :update_current_user) when role in @member do
    req
    |> put_organization_id(:identifier)
    |> Request.put(:identifier, :id, req.requester_id)
  end

  def scope(%{_role_: role} = req, :list_files) when role in @member do
    put_organization_id(req, :filter)
  end

  def scope(%{_role_: role} = req, :reserve_file_location) when role in @admin do
    req
    |> put_organization_id(:data)
    |> Request.put(:data, :owner_id, req.requester_id)
    |> Request.put(:data, :owner, req._requester_)
  end

  def scope(%{_role_: role} = req, :register_file) when role in @admin do
    req
    |> put_organization_id(:data)
    |> Request.put(:data, :owner_id, req.requester_id)
    |> Request.put(:data, :owner, req._requester_)
  end

  def scope(%{_role_: role} = req, :create_audio) when role in @admin do
    put_organization_id(req, :data)
  end

  def scope(%{_role_: role} = req, :list_audios) when role in @admin do
    put_organization_id(req, :filter)
  end

  def scope(%{_role_: role} = req, :list_audios) when role in @member do
    req
    |> put_organization_id(:filter)
    |> Request.add_filter(:status, :published)
  end

  def scope(%{_role_: role} = req, :get_audio) when role in @admin do
    put_organization_id(req, :identifier)
  end

  def scope(%{_role_: role} = req, :get_audio) when role in @guest do
    req
    |> put_organization_id(:identifier)
    |> Request.put(:identifier, :status, :published)
  end

  def scope(%{_role_: role} = req, :update_audio) when role in @admin do
    put_organization_id(req, :identifier)
  end

  def scope(%{_role_: role} = req, :update_audios) when role in @admin do
    put_organization_id(req, :filter)
  end

  def scope(%{_role_: role} = req, :delete_audios) when role in @admin do
    put_organization_id(req, :filter)
  end

  def scope(req, _), do: req

  def authorize(%{_role_: :sysdev} = req, _), do: {:ok, req}
  def authorize(%{_role_: :system} = req, _), do: {:ok, req}
  def authorize(%{_role_: :appdev} = req, _), do: {:ok, req}
  def authorize(%{_role_: :sysops} = req, _), do: {:ok, req}
  def authorize(%{_role_: nil}, _), do: {:error, :access_denied}
  def authorize(%{_client_: nil}, _), do: {:error, :access_denied}
  def authorize(%{organization_id: nil}, _), do: {:error, :access_denied}

  def authorize(%{_role_: role} = req, :get_or_create_user) when role in @anonymous do
    authorize_organization_id(req, :identifier)
  end

  def authorize(%{requester_id: nil}, _), do: {:error, :access_denied}

  def authorize(%{_role_: role} = req, :create_invitation_code) when role in @admin do
    req
    |> authorize_organization_id(:data)
    ~>> authorize_requester_id([:data, :inviter_id])
    ~>> authorize_is_nil([:data, :invitee_role])
  end

  def authorize(%{_role_: role} = req, :sign_up) when role in @guest do
    authorize_requester_id(req, [:identifier, :id])
  end

  def authorize(%{_role_: role} = req, :update_current_user) when role in @member do
    req
    |> authorize_organization_id(:identifier)
    ~>> authorize_requester_id([:identifier, :id])
  end

  def authorize(%{_role_: role} = req, :get_user) when role in @guest do
    authorize_requester_id(req, [:identifier, :id])
  end

  def authorize(%{_role_: role} = req, :get_sharer) when role in @guest do
    authorize_organization_id(req, :identifier)
  end

  def authorize(%{_role_: role} = req, :list_company_accounts) when role in @member do
    authorize_has_filter(req, :id, req._requester_.company_account_id)
  end

  def authorize(%{_role_: role} = req, :reserve_file_location) when role in @admin do
    req
    |> authorize_organization_id(:data)
    ~>> authorize_requester_id([:data, :owner_id])
  end

  def authorize(%{_role_: role} = req, :register_file) when role in @admin do
    req
    |> authorize_organization_id(:data)
    ~>> authorize_requester_id([:data, :owner_id])
  end

  def authorize(%{_role_: role} = req, :create_audio) when role in @admin do
    authorize_organization_id(req, :data)
  end

  def authorize(%{_role_: role} = req, :list_audios) when role in @admin do
    authorize_organization_id(req, :filter)
  end

  def authorize(%{_role_: role} = req, :list_audios) when role in @member do
    req
    |> authorize_organization_id(:filter)
    ~>> authorize_has_filter(:status, :published)
  end

  def authorize(%{_role_: role} = req, :update_audios) when role in @admin do
    authorize_organization_id(req, :filter)
  end

  def authorize(%{_role_: role} = req, :update_audio) when role in @admin do
    authorize_organization_id(req, :identifier)
  end

  def authorize(%{_role_: role} = req, :delete_audios) when role in @admin do
    authorize_organization_id(req, :filter)
  end

  def authorize(%{_role_: role} = req, :list_files) when role in @member do
    authorize_organization_id(req, :filter)
  end

  def authorize(%{_role_: role} = req, :get_audio) when role in @guest do
    authorize_organization_id(req, :identifier)
  end

  def authorize(_, _), do: {:error, :access_denied}

  def put_organization_id(req, :filter) do
    Request.add_filter(req, :organization_id, req.organization_id)
  end

  def put_organization_id(req, key) do
    Request.put(req, key, :organization_id, req.organization_id)
  end

  def authorize_organization_id(req, :filter) do
    authorize_has_filter(req, :organization_id, req.organization_id)
  end

  def authorize_organization_id(%{organization_id: organization_id} = req, key) do
    case get_in(req, [key, :organization_id]) do
      ^organization_id -> {:ok, req}
      _ -> {:error, :access_denied}
    end
  end

  def authorize_requester_id(%{requester_id: requester_id} = req, keys) do
    case get_in(req, keys) do
      ^requester_id -> {:ok, req}
      _ -> {:error, :access_denied}
    end
  end

  def authorize_not_nil(req, keys) do
    case get_in(req, keys) do
      nil -> {:error, :access_denied}
      _ -> {:ok, req}
    end
  end

  def authorize_is_nil(req, keys) do
    case get_in(req, keys) do
      nil -> {:ok, req}
      _ -> {:error, :access_denied}
    end
  end

  def authorize_has_filter(%{filter: filter} = req, filter_key, value) do
    has =
      Enum.any?(filter, fn item ->
        is_map(item) && Map.get(item, filter_key) == value
      end)

    if has do
      {:ok, req}
    else
      {:error, :access_denied}
    end
  end
end
