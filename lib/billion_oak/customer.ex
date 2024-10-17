defmodule BillionOak.Customer do
  @moduledoc """
  The Customer context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias BillionOak.Repo

  alias BillionOak.Customer.{Company, AccountRecord}

  @doc """
  Returns the list of customer_companies.

  ## Examples

      iex> list_companies()
      [%Company{}, ...]

  """
  def list_companies do
    Repo.all(Company)
  end

  @doc """
  Gets a single company.

  ## Examples

      iex> get_company("some handle")
      {:ok, %Company{}}

      iex> get_company("some handle")
      {:error, :not_found}

  """
  def get_company(handle) do
    result = Repo.get_by(Company, handle: handle)

    case result do
      nil -> {:error, :not_found}
      company -> {:ok, company}
    end
  end

  @doc """
  Creates a company.

  ## Examples

      iex> create_company(%{field: value})
      {:ok, %Company{}}

      iex> create_company(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company(attrs \\ %{}) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a company.

  ## Examples

      iex> update_company(company, %{field: new_value})
      {:ok, %Company{}}

      iex> update_company(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_company(%Company{} = company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a company.

  ## Examples

      iex> delete_company(company)
      {:ok, %Company{}}

      iex> delete_company(company)
      {:error, %Ecto.Changeset{}}

  """
  def delete_company(%Company{} = company) do
    Repo.delete(company)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking company changes.

  ## Examples

      iex> change_company(company)
      %Ecto.Changeset{data: %Company{}}

  """
  def change_company(%Company{} = company, attrs \\ %{}) do
    Company.changeset(company, attrs)
  end

  alias BillionOak.Customer.Organization

  @doc """
  Returns the list of customer_organizations.

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

      iex> get_organization(123)
      {:ok, %Organization{}}

      iex> get_organization(456)
      {:error, :not_found}

  """
  def get_organization(id) do
    result = Repo.get(Organization, id)

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

  alias BillionOak.Customer.Account

  @doc """
  Returns the list of customer_accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  def count_accounts do
    Repo.aggregate(Account, :count)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  def get_account_excerpt(rid) do
    account = Repo.get_by(Account, rid: rid)

    case account do
      nil ->
        {:error, :not_found}

      account ->
        excerpt = %{
          id: account.id,
          rid: account.rid,
          phone1: Account.mask_phone(account.phone1),
          phone2: Account.mask_phone(account.phone2)
        }

        {:ok, excerpt}
    end
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def ingest_account_records(data, organization) do
    account_attrs_list = Enum.map(data, & &1.account)
    record_attrs_list = Enum.map(data, & &1.record)

    multi_result =
      Multi.new()
      |> Multi.run(:upsert_accounts, fn _, _ ->
        upsert_accounts(account_attrs_list, organization)
      end)
      |> Multi.run(:insert_account_records, fn _, %{upsert_accounts: accounts} ->
        insert_account_records(record_attrs_list, organization, accounts)
      end)
      |> Repo.transaction()

    case multi_result do
      {:ok, %{upsert_accounts: accounts}} -> {:ok, length(accounts)}
      {:error, _failed_op, reason, _changes} -> {:error, reason}
    end
  end

  defp upsert_accounts(attrs_list, organization) do
    attrs_list
    |> Account.changesets(organization)
    |> Account.upsert_all(returning: [:id, :rid])
  end

  defp insert_account_records(attrs_list, organization, accounts) do
    rid_map = Enum.reduce(accounts, %{}, &Map.put(&2, &1.rid, &1.id))
    attrs_list = Enum.map(attrs_list, &Map.put(&1, :account_id, rid_map[&1.account_rid]))

    attrs_list
    |> AccountRecord.changesets(organization)
    |> AccountRecord.insert_all()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end

  @doc """
  Returns the list of account_records.

  ## Examples

      iex> list_account_records()
      [%AccountRecord{}, ...]

  """
  def list_account_records do
    Repo.all(AccountRecord)
  end

  @doc """
  Gets a single account_record.

  Raises `Ecto.NoResultsError` if the Account record does not exist.

  ## Examples

      iex> get_account_record!(123)
      %AccountRecord{}

      iex> get_account_record!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account_record!(id), do: Repo.get!(AccountRecord, id)

  @doc """
  Creates a account_record.

  ## Examples

      iex> create_account_record(%{field: value})
      {:ok, %AccountRecord{}}

      iex> create_account_record(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account_record(attrs \\ %{}) do
    %AccountRecord{}
    |> AccountRecord.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account_record.

  ## Examples

      iex> update_account_record(account_record, %{field: new_value})
      {:ok, %AccountRecord{}}

      iex> update_account_record(account_record, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_record(%AccountRecord{} = account_record, attrs) do
    account_record
    |> AccountRecord.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account_record.

  ## Examples

      iex> delete_account_record(account_record)
      {:ok, %AccountRecord{}}

      iex> delete_account_record(account_record)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account_record(%AccountRecord{} = account_record) do
    Repo.delete(account_record)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account_record changes.

  ## Examples

      iex> change_account_record(account_record)
      %Ecto.Changeset{data: %AccountRecord{}}

  """
  def change_account_record(%AccountRecord{} = account_record, attrs \\ %{}) do
    AccountRecord.changeset(account_record, attrs)
  end
end
