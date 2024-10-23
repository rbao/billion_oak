defmodule BillionOak.Identity do
  @moduledoc """
  The Identity context.
  """

  import Ecto.Query, warn: false
  alias BillionOak.Repo

  alias BillionOak.Identity.{Client, Organization}

  @doc """
  Returns the list of External_organizations.

  ## Examples

      iex> list_organizations()
      [%Organization{}, ...]

  """
  def list_organizations do
    Repo.all(Organization)
  end

  @doc """
  Gets a single organization.

  ## Examples

      iex> get_organization(%{handle: "happyteam"})
      {:ok, %Organization{}}

      iex> get_organization(%{handle: "happyteam"})
      {:error, :not_found}

  """
  def get_organization(identifier) do
    result = Repo.get_by(Organization, identifier)

    case result do
      nil -> {:error, :not_found}
      organization -> {:ok, organization}
    end
  end

  def get_organization(company_id, handle) do
    result = Repo.get_by(Organization, company_id: company_id, handle: handle)

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
    Repo.all(Client)
    |> Client.put_publishable_key()
  end

  @doc """
  Gets a single client.

  Raises `Ecto.NoResultsError` if the Client does not exist.

  ## Examples

      iex> get_client!(123)
      %Client{}

      iex> get_client!(456)
      ** (Ecto.NoResultsError)

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
  Returns an `%Ecto.Changeset{}` for tracking client changes.

  ## Examples

      iex> change_client(client)
      %Ecto.Changeset{data: %Client{}}

  """
  def change_client(%Client{} = client, attrs \\ %{}) do
    Client.changeset(client, attrs)
  end

  alias BillionOak.Identity.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
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

  def create_or_get_user(identifier, attrs) do
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
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias BillionOak.Identity.InvitationCode

  @doc """
  Returns the list of invitation_codes.

  ## Examples

      iex> list_invitation_codes()
      [%InvitationCode{}, ...]

  """
  def list_invitation_codes do
    Repo.all(InvitationCode)
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
end
