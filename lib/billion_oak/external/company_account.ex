defmodule BillionOak.External.CompanyAccount do
  use BillionOak.Schema, id_prefix: "cpacc"
  alias BillionOak.{Repo, Validation}
  alias BillionOak.External.{Company, Organization}

  schema "company_accounts" do
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

  def changeset(account, input_list) when is_list(input_list) do
    Enum.map(input_list, fn input ->
      changeset(account, input)
    end)
  end

  def changeset(account, input) do
    account
    |> changeset()
    |> cast(input, castable_fields())
    |> validate_required([:rid, :status, :name, :company_id, :organization_id])
  end

  def mask_phone(nil), do: nil

  def mask_phone(phone) do
    {prefix, last_four} = String.split_at(phone, -4)
    String.duplicate("*", String.length(prefix)) <> last_four
  end

  def upsert_all(changesets, opts \\ []) do
    error_changesets = Validation.invalid_changesets(changesets, :index)

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
