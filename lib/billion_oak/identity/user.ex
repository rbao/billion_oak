defmodule BillionOak.Identity.User do
  use BillionOak.Schema, id_prefix: "usr"

  alias BillionOak.External
  alias BillionOak.External.CompanyAccount
  alias BillionOak.Identity.Organization
  alias BillionOak.Filestore.File
  alias BillionOak.Repo

  schema "users" do
    field :share_id, :string
    field :status, Ecto.Enum, values: [:active, :suspended], default: :active
    field :role, Ecto.Enum, values: [:guest, :member, :admin], default: :guest
    field :first_name, :string
    field :last_name, :string
    field :payment_due_date, :date
    field :company_account_rid, :string, virtual: true
    field :wx_app_openid, :string
    field :avatar_file_id, :string
    field :avatar_file, :map, virtual: true

    timestamps()

    belongs_to :inviter, __MODULE__
    belongs_to :organization, Organization
    belongs_to :company_account, CompanyAccount
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([
      :role,
      :organization_id
    ])
    |> put_share_id()
    |> put_company_account()
    |> put_company_account_id()
    |> put_avatar_file()
    |> validate_avatar_file()
  end

  defp put_share_id(cs) do
    if get_field(cs, :share_id) do
      cs
    else
      change(cs, share_id: generate_id())
    end
  end

  defp put_company_account(%{valid?: false} = cs), do: cs

  defp put_company_account(%{data: data, changes: %{company_account_rid: rid}} = cs) do
    organization_id = get_field(cs, :organization_id)

    case External.get_company_account(organization_id: organization_id, rid: rid) do
      {:ok, company_account} ->
        Map.put(cs, :data, %{data | company_account: company_account})

      {:error, :not_found} ->
        add_error(cs, :company_account_rid, "does not exist", validation: :must_exist)
    end
  end

  defp put_company_account(cs), do: cs

  defp put_company_account_id(%{valid?: false} = cs), do: cs

  defp put_company_account_id(
         %{data: %{company_account: %{id: id}, company_account_id: nil}} = cs
       ) do
    change(cs, company_account_id: id)
  end

  defp put_company_account_id(cs), do: cs

  defp put_avatar_file(%{valid?: true, changes: %{avatar_file_id: avatar_file_id}} = cs) do
    organization_id = get_field(cs, :organization_id)

    file =
      File
      |> Repo.get_by(id: avatar_file_id, organization_id: organization_id)
      |> File.put_url()

    change(cs, avatar_file: file)
  end

  defp put_avatar_file(cs), do: cs

  defp validate_avatar_file(%{valid?: true, changes: %{avatar_file_id: _}} = cs) do
    if get_field(cs, :avatar_file) do
      cs
    else
      add_error(cs, :avatar_file_id, "does not exist", validation: :must_exist)
    end
  end

  defp validate_avatar_file(cs), do: cs
end
