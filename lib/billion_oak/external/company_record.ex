defmodule BillionOak.External.CompanyRecord do
  use BillionOak.Schema, id_prefix: "cprec"
  alias BillionOak.{Repo, Validation}
  alias BillionOak.External.{Company, Organization, CompanyCompanyAccount}

  schema "company_records" do
    field :dedupe_id, :string
    field :content, :map

    timestamps()

    belongs_to :company, Company
    belongs_to :organization, Organization
    belongs_to :company_account, CompanyCompanyAccount
  end

  @doc false
  def changeset(company_record, attrs) do
    company_record
    |> changeset()
    |> cast(attrs, castable_fields())
    |> put_dedupe_id()
    |> validate_required([:dedupe_id, :content, :company_id, :organization_id, :company_account_id])
  end

  def changesets(attrs_list, organization) do
    Enum.map(attrs_list, fn attrs ->
      attrs =
        Map.merge(attrs, %{
          company_id: organization.company_id,
          organization_id: organization.id
        })

      changeset(%__MODULE__{}, attrs)
    end)
  end

  defp put_dedupe_id(%{changes: %{content: content}} = changeset) do
    md5 =
      :md5
      |> :crypto.hash(Jason.encode!(content))
      |> Base.encode16(case: :lower)

    change(changeset, dedupe_id: md5)
  end

  defp put_dedupe_id(changeset), do: changeset

  def insert_all(changesets) do
    error_changesets = Validation.invalid_changesets(changesets)

    if Enum.empty?(error_changesets) do
      {count, _} =
        Repo.insert_all(__MODULE__, entries(changesets),
          on_conflict: :nothing,
          conflict_target: [:dedupe_id]
        )

      {:ok, count}
    else
      {:error, error_changesets}
    end
  end
end
