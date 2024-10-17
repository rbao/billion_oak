defmodule BillionOak.External do
  @moduledoc """
  The External context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias BillionOak.Repo

  alias BillionOak.External.{Company, CompanyAccount, CompanyRecord}

  @doc """
  Returns the list of External_companies.

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

  @doc """
  Returns the list of External_accounts.

  ## Examples

      iex> list_company_accounts()
      [%CompanyAccount{}, ...]

  """
  def list_company_accounts do
    Repo.all(CompanyAccount)
  end

  def count_company_accounts do
    Repo.aggregate(CompanyAccount, :count)
  end

  @doc """
  Gets a single company account.

  Raises `Ecto.NoResultsError` if the CompanyAccount does not exist.

  ## Examples

      iex> get_company_account(123)
      {:ok, %CompanyAccount{}}

      iex> get_company_account(456)
      {:error, :not_found}

  """
  def get_company_account(id) do
    result = Repo.get(CompanyAccount, id)

    case result do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end

  def get_company_account_excerpt(rid) do
    account = Repo.get_by(CompanyAccount, rid: rid)

    case account do
      nil ->
        {:error, :not_found}

      account ->
        excerpt = %{
          id: CompanyAccount.prefix_id(account.id),
          rid: account.rid,
          phone1: CompanyAccount.mask_phone(account.phone1),
          phone2: CompanyAccount.mask_phone(account.phone2)
        }

        {:ok, excerpt}
    end
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_company_account(%{field: value})
      {:ok, %CompanyAccount{}}

      iex> create_company_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company_account(attrs \\ %{}) do
    %CompanyAccount{}
    |> CompanyAccount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_company_account(account, %{field: new_value})
      {:ok, %CompanyAccount{}}

      iex> update_company_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_company_account(%CompanyAccount{} = account, attrs) do
    account
    |> CompanyAccount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %CompanyAccount{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_company_account(%CompanyAccount{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %CompanyAccount{}}

  """
  def change_account(%CompanyAccount{} = account, attrs \\ %{}) do
    CompanyAccount.changeset(account, attrs)
  end

  @doc """
  Returns the list of company_records.

  ## Examples

      iex> list_company_records()
      [%CompanyRecord{}, ...]

  """
  def list_company_records do
    Repo.all(CompanyRecord)
  end

  @doc """
  Gets a single company_record.

  Raises `Ecto.NoResultsError` if the company record does not exist.

  ## Examples

      iex> get_company_record!(123)
      %CompanyRecord{}

      iex> get_company_record!(456)
      ** (Ecto.NoResultsError)

  """
  def get_company_record(id) do
    result = Repo.get(CompanyRecord, id)

    case result do
      nil -> {:error, :not_found}
      company_record -> {:ok, company_record}
    end
  end

  @doc """
  Creates a company_record.

  ## Examples

      iex> create_company_record(%{field: value})
      {:ok, %CompanyRecord{}}

      iex> create_company_record(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company_record(attrs \\ %{}) do
    %CompanyRecord{}
    |> CompanyRecord.changeset(attrs)
    |> Repo.insert()
  end

  def ingest_company_records(data, organization) do
    account_attrs_list = Enum.map(data, & &1.account)
    record_attrs_list = Enum.map(data, & &1.record)

    multi_result =
      Multi.new()
      |> Multi.run(:upsert_accounts, fn _, _ ->
        upsert_accounts(account_attrs_list, organization)
      end)
      |> Multi.run(:insert_company_records, fn _, %{upsert_accounts: accounts} ->
        insert_company_records(record_attrs_list, organization, accounts)
      end)
      |> Repo.transaction()

    case multi_result do
      {:ok, %{upsert_accounts: accounts}} -> {:ok, length(accounts)}
      {:error, _failed_op, reason, _changes} -> {:error, reason}
    end
  end

  defp upsert_accounts(attrs_list, organization) do
    attrs_list
    |> CompanyAccount.changesets(organization)
    |> CompanyAccount.upsert_all(returning: [:id, :rid])
  end

  defp insert_company_records(attrs_list, organization, accounts) do
    rid_map = Enum.reduce(accounts, %{}, &Map.put(&2, &1.rid, &1.id))

    attrs_list =
      Enum.map(attrs_list, &Map.put(&1, :company_account_id, rid_map[&1.company_account_rid]))

    attrs_list
    |> CompanyRecord.changesets(organization)
    |> CompanyRecord.insert_all()
  end

  @doc """
  Updates a company_record.

  ## Examples

      iex> update_company_record(company_record, %{field: new_value})
      {:ok, %CompanyRecord{}}

      iex> update_company_record(company_record, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_company_record(%CompanyRecord{} = company_record, attrs) do
    company_record
    |> CompanyRecord.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a company_record.

  ## Examples

      iex> delete_company_record(company_record)
      {:ok, %CompanyRecord{}}

      iex> delete_company_record(company_record)
      {:error, %Ecto.Changeset{}}

  """
  def delete_company_record(%CompanyRecord{} = company_record) do
    Repo.delete(company_record)
  end
end
