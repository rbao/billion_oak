defmodule BillionOak.Customer.Account do
  use BillionOak.Schema, id_prefix: "acct"
  alias BillionOak.Repo
  alias BillionOak.Customer.{Company, Organization, Account}

  schema "customer_accounts" do
    field :is_root, :boolean, default: false
    field :status, Ecto.Enum, values: [:active, :inactive, :terminated], default: :active
    field :name, :string
    field :state, :string
    field :number, :string
    field :enroller_number, :string
    field :sponsor_number, :string
    field :country_code, :string
    field :phone1, :string
    field :phone2, :string
    field :city, :string
    field :enrolled_at, :utc_datetime

    timestamps()

    belongs_to :company, Company
    belongs_to :organization, Organization
    belongs_to :enroller, Account
    belongs_to :sponsor, Account
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([:number, :status, :name, :company_id, :organization_id])
  end

  def upsert_all(changesets) do
    error_changesets =
      changesets
      |> Enum.with_index()
      |> Enum.reduce([], fn {changeset, index}, acc ->
        if changeset.valid? do
          acc
        else
          acc ++ [{index, changeset}]
        end
      end)

    if Enum.empty?(error_changesets) do
      now = DateTime.utc_now(:second)

      entries =
        Enum.map(changesets, fn changeset ->
          changeset.data
          |> Map.take(castable_fields())
          |> Map.merge(changeset.changes)
          |> Map.merge(%{
            inserted_at: now,
            updated_at: now
          })
        end)

      # Repo.insert_all(Account, entries,
      #   on_conflict: {:replace_all_except, [:id, :inserted_at]},
      #   conflict_target: [:company_id, :organization_id, :number]
      # )
      {count, _} =
        Repo.insert_all(__MODULE__, entries,
          on_conflict: {:replace_all_except, [:id, :inserted_at]},
          conflict_target: [:company_id, :organization_id, :number]
        )

      {:ok, count}
    else
      {:error, error_changesets}
    end
  end
end
