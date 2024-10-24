defmodule BillionOak.Identity.InvitationCode do
  alias BillionOak.Identity.{Organization, User}
  alias BillionOak.External.CompanyAccount
  alias BillionOak.Repo
  use BillionOak.Schema, id_prefix: "incd"

  schema "invitation_codes" do
    field :value, :string
    field :invitee_company_account_rid, :string
    field :expires_at, :utc_datetime

    timestamps()

    belongs_to :organization, Organization
    belongs_to :inviter, User
  end

  @doc false
  def changeset(invitation_code, attrs) do
    invitation_code
    |> changeset()
    |> cast(attrs, [:inviter_id, :organization_id, :invitee_company_account_rid, :expires_at])
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

    is_exists = !!Repo.get_by(CompanyAccount, organization_id: org_id, rid: rid)

    if is_exists do
      changeset
    else
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
end
