defmodule BillionOak.Customer.Account do
  use BillionOak.Schema, id_prefix: "acct"
  alias BillionOak.{Repo, Validation}
  alias BillionOak.Customer.{Company, Organization}

  schema "customer_accounts" do
    field :is_root, :boolean, default: false
    field :status, Ecto.Enum, values: [:active, :inactive, :terminated], default: :active
    field :name, :string
    field :state, :string
    field :rid, :string
    field :enroller_rid, :string
    field :sponsor_rid, :string
    field :country_code, :string
    field :phone1, :string
    field :phone2, :string
    field :city, :string
    field :enrolled_at, :utc_datetime
    field :custom_data, :map

    timestamps()

    belongs_to :company, Company
    belongs_to :organization, Organization
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([:rid, :status, :name, :company_id, :organization_id])
  end

  def changesets(attrs_list, organization) do
    Enum.map(attrs_list, fn attrs ->
      attrs =
        Map.merge(attrs, %{
          company_id: organization.company_id,
          organization_id: organization.id
        })

      changeset = changeset(%__MODULE__{}, attrs)

      if attrs.rid == organization.root_account_rid do
        change(changeset, is_root: true)
      else
        changeset
      end
    end)
  end

  def upsert_all(changesets, opts \\ []) do
    error_changesets = Validation.invalid_changesets(changesets)

    if Enum.empty?(error_changesets) do
      {count, fields} =
        Repo.insert_all(__MODULE__, entries(changesets),
          on_conflict: {:replace_all_except, [:id, :inserted_at]},
          conflict_target: [:company_id, :organization_id, :rid],
          returning: opts[:returning] || false
        )

      if opts[:returning] do
        {:ok, fields}
      else
        {:ok, count}
      end
    else
      {:error, error_changesets}
    end
  end
end
