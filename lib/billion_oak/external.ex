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
      {:ok, [%Company{}, ...]}

  """
  def list_companies(_ \\ nil) do
    {:ok, Repo.all(Company)}
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
  Returns the list of External_accounts.

  ## Examples

      iex> list_company_accounts()
      {:ok, [%CompanyAccount{}, ...]}

  """
  def list_company_accounts(_ \\ nil) do
    {:ok, Repo.all(CompanyAccount)}
  end

  def count_company_accounts(_ \\ nil) do
    {:ok, Repo.aggregate(CompanyAccount, :count)}
  end

  @doc """
  Gets a single company account.

  ## Examples

      iex> get_company_account(123)
      {:ok, %CompanyAccount{}}

      iex> get_company_account(456)
      {:error, :not_found}

  """
  def get_company_account(identifier) do
    result = Repo.get_by(CompanyAccount, identifier)

    case result do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end

  def get_company_account_excerpt(identifier) do
    account = Repo.get_by(CompanyAccount, identifier)

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
  Returns the list of company_records.

  ## Examples

      iex> list_company_records()
      {:ok, [%CompanyRecord{}, ...]}

  """
  def list_company_records(_ \\ nil) do
    {:ok, Repo.all(CompanyRecord)}
  end

  def count_company_records(_ \\ nil) do
    {:ok, Repo.aggregate(CompanyRecord, :count)}
  end

  @doc """
  Gets a single company_record.

  ## Examples

      iex> get_company_record(123)
      {:ok, %CompanyRecord{}}

      iex> get_company_record(456)
      {:error, :not_found}

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

  def ingest_data(data) do
    account_input_list = Enum.map(data, & &1.account)
    record_input_list = Enum.map(data, & &1.record)

    multi_result =
      Multi.new()
      |> Multi.run(:upsert_accounts, fn _, _ ->
        upsert_accounts(account_input_list)
      end)
      |> Multi.run(:insert_company_records, fn _, %{upsert_accounts: accounts} ->
        insert_company_records(record_input_list, accounts)
      end)
      |> Repo.transaction()

    case multi_result do
      {:ok, %{upsert_accounts: accounts}} -> {:ok, length(accounts)}
      {:error, _failed_op, reason, _changes} -> {:error, reason}
    end
  end

  defp upsert_accounts(input_list) do
    %CompanyAccount{}
    |> CompanyAccount.changeset(input_list)
    |> CompanyAccount.upsert_all(returning: [:id, :rid])
  end

  defp insert_company_records(input_list, accounts) do
    rid_map = Enum.reduce(accounts, %{}, &Map.put(&2, &1.rid, &1.id))

    input_list =
      Enum.map(input_list, &Map.put(&1, :company_account_id, rid_map[&1.company_account_rid]))

    %CompanyRecord{}
    |> CompanyRecord.changeset(input_list)
    |> CompanyRecord.insert_all()
  end
end
