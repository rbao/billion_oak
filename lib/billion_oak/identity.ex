defmodule BillionOak.Identity do
  @moduledoc """
  The Identity context.
  """

  use OK.Pipe
  import Ecto.Query, warn: false
  alias BillionOak.Repo

  alias BillionOak.Identity.{Client, Organization, User, InvitationCode}

  @doc """
  Returns the list of External_organizations.

  ## Examples

      iex> list_organizations()
      {:ok, [%Organization{}, ...]}

  """
  def list_organizations do
    {:ok, Repo.all(Organization)}
  end

  @doc """
  Gets a single organization.

  ## Examples

      iex> get_organization(%{handle: "happyteam"})
      {:ok, %Organization{}}

      iex> get_organization(%{handle: "happyteam"})
      {:error, :not_found}

  """
  def get_organization(%{identifier: identifier}) do
    result = Repo.get_by(Organization, identifier)

    case result do
      nil -> {:error, :not_found}
      organization -> {:ok, organization}
    end
  end

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  @doc """
  Returns the list of clients.

  ## Examples

      iex> list_clients()
      [%Client{}, ...]

  """
  def list_clients do
    clients =
      Repo.all(Client)
      |> Client.put_publishable_key()

    {:ok, clients}
  end

  @doc """
  Gets a single client.

  ## Examples

      iex> get_client!(123)
      {:ok, %Client{}}

      iex> get_client!(456)
      {:error, :not_found}

  """
  def get_client(id) do
    result =
      Client
      |> Repo.get(id)
      |> Client.put_publishable_key()

    case result do
      nil -> {:error, :not_found}
      client -> {:ok, client}
    end
  end

  def verify_client(id, secret) do
    case get_client(id) do
      {:ok, %{secret: ^secret} = client} -> {:ok, client}
      _ -> {:error, :invalid}
    end
  end

  @doc """
  Creates a client.

  ## Examples

      iex> create_client(%{field: value})
      {:ok, %Client{}}

      iex> create_client(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_client(attrs \\ %{}) do
    %Client{}
    |> Client.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a client.

  ## Examples

      iex> update_client(client, %{field: new_value})
      {:ok, %Client{}}

      iex> update_client(client, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_client(%Client{} = client, attrs) do
    client
    |> Client.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a client.

  ## Examples

      iex> delete_client(client)
      {:ok, %Client{}}

      iex> delete_client(client)
      {:error, %Ecto.Changeset{}}

  """
  def delete_client(%Client{} = client) do
    Repo.delete(client)
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      {:ok, [%User{}, ...]}

  """
  def list_users do
    {:ok, Repo.all(User)}
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user(123)
      {:ok, %User{}}

      iex> get_user(456)
      {:error, :not_found}

  """
  def get_user(identifier) do
    result = Repo.get_by(User, identifier)

    case result do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_or_create_user(identifier, attrs) do
    attrs = Map.merge(attrs, identifier)

    case get_user(identifier) do
      {:ok, user} -> {:ok, user}
      {:error, :not_found} -> create_user(attrs)
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns the list of invitation_codes.

  ## Examples

      iex> list_invitation_codes()
      {:ok, [%InvitationCode{}, ...]}

  """
  def list_invitation_codes do
    {:ok, Repo.all(InvitationCode)}
  end

  @doc """
  Gets a single invitation_code.

  Raises `Ecto.NoResultsError` if the Invitation code does not exist.

  ## Examples

      iex> get_invitation_code(123)
      {:ok, %InvitationCode{}}

      iex> get_invitation_code!(456)
      {:error, :not_found}

  """
  def get_invitation_code(value) do
    result = Repo.get_by(InvitationCode, value: value)

    case result do
      nil -> {:error, :not_found}
      invitation_code -> {:ok, invitation_code}
    end
  end

  @doc """
  Creates a invitation_code.

  ## Examples

      iex> create_invitation_code(%{field: value})
      {:ok, %InvitationCode{}}

      iex> create_invitation_code(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invitation_code(attrs \\ %{}) do
    %InvitationCode{inviter: attrs[:inviter]}
    |> InvitationCode.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a invitation_code.

  ## Examples

      iex> delete_invitation_code(invitation_code)
      {:ok, %InvitationCode{}}

      iex> delete_invitation_code(invitation_code)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invitation_code(%InvitationCode{} = invitation_code) do
    Repo.delete(invitation_code)
  end

  def sign_up(guest_id, %{company_account_rid: rid, invitation_code: inv_code_value} = params) do
    guest = Repo.get_by(User, id: guest_id, role: :guest)
    initial = if guest, do: {:ok, guest}, else: {:error, :not_found}

    result =
      initial
      ~>> then(&verify_invitation_code(inv_code_value, &1.organization_id, rid))
      ~> then(
        &User.changeset(guest, %{
          first_name: params[:first_name],
          last_name: params[:last_name],
          company_account_rid: &1.invitee_company_account_rid,
          inviter_id: &1.inviter_id,
          role: &1.invitee_role
        })
      )
      ~>> Repo.update()

    case result do
      {:error, :invalid} -> {:error, :invalid_invitation_code}
      other -> other
    end
  end

  defp verify_invitation_code(nil, _, _), do: {:error, :invalid}
  defp verify_invitation_code(_, nil, _), do: {:error, :invalid}
  defp verify_invitation_code(_, _, nil), do: {:error, :invalid}

  defp verify_invitation_code(value, org_id, rid) do
    inv_code =
      Repo.get_by(InvitationCode,
        value: value,
        organization_id: org_id,
        invitee_company_account_rid: rid
      )

    case inv_code do
      nil -> {:error, :invalid}
      _ -> {:ok, inv_code}
    end
  end
end
