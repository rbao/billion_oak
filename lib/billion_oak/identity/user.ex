defmodule BillionOak.Identity.User do
  use BillionOak.Schema, id_prefix: "usr"
  alias BillionOak.Identity.Organization
  alias BillionOak.External.CompanyAccount
  alias BillionOak.Repo

  schema "users" do
    field :role, Ecto.Enum, values: [:guest, :member, :admin], default: :guest
    field :first_name, :string
    field :last_name, :string
    field :company_account_rid, :string, virtual: true
    field :wx_app_openid, :string

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
      :organization_id,
    ])
    |> put_company_account()
    |> put_company_account_id()
  end

  defp put_company_account(%{valid?: false} = cs), do: cs
  defp put_company_account(%{data: data, changes: %{company_account_rid: rid}} = cs) do
    company_account = Repo.get_by(CompanyAccount, rid: rid)
    if company_account do
      Map.put(cs, :data, %{data | company_account: company_account})
    else
      add_error(cs, :company_account_rid, "does not exist", validation: :must_exist)
    end
  end
  defp put_company_account(cs), do: cs

  defp put_company_account_id(%{valid?: false} = cs), do: cs
  defp put_company_account_id(%{data: %{company_account: %{id: id}, company_account_id: nil}} = cs) do
    IO.inspect "here2"
    change(cs, company_account_id: id)
  end
  defp put_company_account_id(cs), do: cs
end
