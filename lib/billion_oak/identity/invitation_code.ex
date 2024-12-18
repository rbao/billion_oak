defmodule BillionOak.Identity.InvitationCode do
  use BillionOak.Schema, id_prefix: "incd"

  alias BillionOak.External
  alias BillionOak.Repo
  alias BillionOak.Identity.{Organization, User}

  schema "invitation_codes" do
    field :value, :string
    field :status, Ecto.Enum, values: [:active, :used], default: :active
    field :invitee_company_account_rid, :string
    field :invitee_role, Ecto.Enum, values: [:member, :admin], default: :member
    field :expires_at, :utc_datetime
    field :payment_due_date, :date

    timestamps()

    belongs_to :organization, Organization
    belongs_to :inviter, User
  end

  def changeset(invitation_code, :update, attrs) do
    invitation_code
    |> changeset()
    |> cast(attrs, [:status])
  end

  @doc false
  def changeset(invitation_code, :create, attrs) do
    invitation_code
    |> changeset()
    |> cast(attrs, castable_fields() -- [:value])
    |> validate_required([:invitee_company_account_rid])
    |> put_inviter()
    |> validate_inviter_id()
    |> put_organization_id()
    |> validate_required([:organization_id])
    |> validate_organization_id()
    |> validate_invitee()
    |> put_value()
    |> put_expires_at()
  end

  defp put_inviter(%{valid?: false} = changeset), do: changeset
  defp put_inviter(%{data: %{inviter: %{id: _}}} = changeset), do: changeset

  defp put_inviter(%{data: data, changes: %{inviter_id: inviter_id}} = changeset) do
    inviter = Repo.get(User, inviter_id)
    Map.put(changeset, :data, %{data | inviter: inviter})
  end

  defp put_inviter(changeset), do: changeset

  defp validate_inviter_id(%{valid?: false} = changeset), do: changeset

  defp validate_inviter_id(
         %{data: %{inviter: nil}, changes: %{inviter_id: inviter_id}} = changeset
       )
       when is_binary(inviter_id) do
    add_error(changeset, :inviter_id, "does not exist", validation: :must_exist)
  end

  defp validate_inviter_id(%{data: %{inviter: %{id: valid_id}}} = changeset) do
    if get_change(changeset, :inviter_id) == valid_id do
      changeset
    else
      add_error(changeset, :inviter_id, "does not match", validation: :must_match)
    end
  end

  defp validate_inviter_id(changeset), do: changeset

  defp put_organization_id(%{valid?: false} = changeset), do: changeset
  defp put_organization_id(%{data: %{inviter: nil}} = changeset), do: changeset

  defp put_organization_id(%{data: %{inviter: inviter}} = changeset) do
    change(changeset, organization_id: inviter.organization_id)
  end

  defp validate_organization_id(%{valid?: false} = changeset), do: changeset
  defp validate_organization_id(%{data: %{inviter: %{id: _}}} = changeset), do: changeset

  defp validate_organization_id(%{data: %{inviter: nil}} = changeset) do
    organization_id = get_change(changeset, :organization_id)

    if Repo.exists?(Organization, id: organization_id) do
      changeset
    else
      add_error(changeset, :organization_id, "does not exist", validation: :must_exist)
    end
  end

  defp validate_invitee(%{valid?: false} = changeset), do: changeset

  defp validate_invitee(%{changes: %{invitee_company_account_rid: rid}} = changeset) do
    org_id = get_change(changeset, :organization_id)

    case External.get_company_account(organization_id: org_id, rid: rid) do
      {:ok, _} ->
        changeset

      {:error, :not_found} ->
        add_error(changeset, :invitee_company_account_rid, "does not exist",
          validation: :must_exist
        )
    end
  end

  defp put_value(%{valid?: false} = changeset), do: changeset
  defp put_value(changeset), do: change(changeset, value: generate_value())

  defp generate_value() do
    allowed_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    for _ <- 1..6, into: "", do: <<Enum.random(String.to_charlist(allowed_chars))>>
  end

  defp put_expires_at(%{valid?: false} = changeset), do: changeset
  defp put_expires_at(%{changes: %{expires_at: _}} = changeset), do: changeset

  defp put_expires_at(changeset) do
    change(changeset, expires_at: DateTime.add(DateTime.utc_now(:second), 30, :day))
  end

  def verify(nil, _, _), do: {:error, :invalid}
  def verify(_, nil, _), do: {:error, :invalid}
  def verify(_, _, nil), do: {:error, :invalid}

  def verify(value, org_id, rid) do
    inv_code =
      Repo.get_by(__MODULE__,
        value: value,
        status: :active,
        organization_id: org_id,
        invitee_company_account_rid: rid
      )

    case inv_code do
      nil -> {:error, :invalid}
      _ -> {:ok, inv_code}
    end
  end
end
