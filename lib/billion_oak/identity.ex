defmodule BillionOak.Identity do
  @moduledoc """
  The Identity context.
  """

  use OK.Pipe
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias BillionOak.Repo

  alias BillionOak.Identity.{Client, Organization, User, InvitationCode}

  def list_organizations(_ \\ nil) do
    {:ok, Repo.all(Organization)}
  end

  def get_organization(%{identifier: identifier}) do
    result = Repo.get_by(Organization, identifier)

    case result do
      nil -> {:error, :not_found}
      organization -> {:ok, organization}
    end
  end

  def create_organization(%{data: data}), do: create_organization(data)

  def create_organization(data) do
    %Organization{}
    |> Organization.changeset(data)
    |> Repo.insert()
  end

  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  def delete_organization(req) do
    get_organization(req)
    ~>> Repo.delete()
  end

  def list_clients(_ \\ nil) do
    clients =
      Repo.all(Client)
      |> Client.put_publishable_key()

    {:ok, clients}
  end

  def get_client(%{identifier: identifier}), do: get_client(identifier)

  def get_client(identifier) do
    result =
      Client
      |> Repo.get_by(identifier)
      |> Client.put_publishable_key()

    case result do
      nil -> {:error, :not_found}
      client -> {:ok, client}
    end
  end

  def verify_client(%{identifier: _, data: %{secret: secret}} = req) do
    case get_client(req) do
      {:ok, %{secret: ^secret} = client} -> {:ok, client}
      _ -> {:error, :invalid}
    end
  end

  def create_client(%{data: data}), do: create_client(data)

  def create_client(data) do
    %Client{}
    |> Client.changeset(data)
    |> Repo.insert()
    ~> then(&Client.put_publishable_key(&1))
  end

  def update_client(%{identifier: _, data: data} = req) do
    get_client(req)
    ~> Client.changeset(data)
    ~>> Repo.update()
  end

  def delete_client(req) do
    get_client(req)
    ~>> Repo.delete()
  end

  def list_users(_ \\ nil) do
    {:ok, Repo.all(User)}
  end

  def get_user(%{identifier: identifier}), do: get_user(identifier)

  def get_user(identifier) do
    result = Repo.get_by(User, identifier)

    case result do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def get_sharer(%{identifier: identifier} = req) do
    identifier =
      identifier
      |> Map.put(:share_id, identifier[:id])
      |> Map.drop([:id])

    req
    |> Map.put(:identifier, identifier)
    |> get_user()
  end

  def create_user(data) do
    %User{}
    |> User.changeset(data)
    |> Repo.insert()
  end

  def get_or_create_user(%{identifier: identifier, data: data} = req) do
    case get_user(req) do
      {:ok, user} ->
        {:ok, user}

      {:error, :not_found} ->
        data
        |> Map.merge(identifier)
        |> create_user()
    end
  end

  def update_user(%{data: data} = req) do
    get_user(req)
    ~> User.changeset(data)
    ~>> Repo.update()
  end

  def delete_user(req) do
    get_user(req)
    ~>> Repo.delete()
  end

  def list_invitation_codes(_ \\ nil) do
    {:ok, Repo.all(InvitationCode)}
  end

  def get_invitation_code(%{identifier: identifier}) do
    result = Repo.get_by(InvitationCode, identifier)

    case result do
      nil -> {:error, :not_found}
      invitation_code -> {:ok, invitation_code}
    end
  end

  def create_invitation_code(%{data: data}) do
    %InvitationCode{inviter: data[:inviter]}
    |> InvitationCode.changeset(:create, data)
    |> Repo.insert()
  end

  def delete_invitation_code(req) do
    get_invitation_code(req)
    ~>> Repo.delete()
  end

  def sign_up(%{identifier: %{id: _} = identifier, data: data}) do
    identifier = Map.put(identifier, :role, :guest)
    initial = get_user(%{identifier: identifier})

    guest =
      case initial do
        {:ok, guest} -> guest
        _ -> nil
      end

    inv_code_value = data[:invitation_code]
    rid = data[:company_account_rid]

    result =
      initial
      ~>> then(&InvitationCode.verify(inv_code_value, &1.organization_id, rid))
      ~>> then(&do_sign_up(guest, data, &1))

    case result do
      {:error, :invalid} -> {:error, :invalid_invitation_code}
      other -> other
    end
  end

  defp do_sign_up(guest, data, inv_code) do
    inv_changeset = InvitationCode.changeset(inv_code, :update, %{status: :used})

    user_changeset =
      User.changeset(guest, %{
        first_name: data[:first_name],
        last_name: data[:last_name],
        company_account_rid: inv_code.invitee_company_account_rid,
        inviter_id: inv_code.inviter_id,
        role: inv_code.invitee_role
      })

    result =
      Multi.new()
      |> Multi.update(:user, user_changeset)
      |> Multi.update(:invitation_code, inv_changeset)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, _op, value, _changes} -> {:error, value}
    end
  end
end
