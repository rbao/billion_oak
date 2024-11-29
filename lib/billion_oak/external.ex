defmodule BillionOak.External do
  @moduledoc """
  The External context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias BillionOak.{Repo, Query}

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

  def get_company(handle) do
    result = Repo.get_by(Company, handle: handle)

    case result do
      nil -> {:error, :not_found}
      company -> {:ok, company}
    end
  end

  def create_company(%{data: data}), do: create_company(data)

  def create_company(data) do
    %Company{}
    |> Company.changeset(data)
    |> Repo.insert()
  end

  def update_company(%Company{} = company, data) do
    company
    |> Company.changeset(data)
    |> Repo.update()
  end

  def delete_company(%Company{} = company) do
    Repo.delete(company)
  end

  def list_company_accounts(req \\ %{}) do
    result =
      CompanyAccount
      |> Query.to_query()
      |> Query.filter(req[:filter], req[:_filterable_keys_])
      |> Query.sort(req[:sort], req[:_sortable_keys_])
      |> Query.paginate(req[:pagination])
      |> Repo.all()

    {:ok, result}
  end

  def count_company_accounts(_ \\ nil) do
    {:ok, Repo.aggregate(CompanyAccount, :count)}
  end

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

  def create_company_account(data \\ %{}) do
    %CompanyAccount{}
    |> CompanyAccount.changeset(data)
    |> Repo.insert()
  end

  def update_company_account(%CompanyAccount{} = account, data) do
    account
    |> CompanyAccount.changeset(data)
    |> Repo.update()
  end

  def delete_company_account(%CompanyAccount{} = account) do
    Repo.delete(account)
  end

  def list_company_records(_ \\ nil) do
    {:ok, Repo.all(CompanyRecord)}
  end

  def count_company_records(_ \\ nil) do
    {:ok, Repo.aggregate(CompanyRecord, :count)}
  end

  def get_company_record(id) do
    result = Repo.get(CompanyRecord, id)

    case result do
      nil -> {:error, :not_found}
      company_record -> {:ok, company_record}
    end
  end

  def create_company_record(data \\ %{}) do
    %CompanyRecord{}
    |> CompanyRecord.changeset(data)
    |> Repo.insert()
  end

  def update_company_record(%CompanyRecord{} = company_record, data) do
    company_record
    |> CompanyRecord.changeset(data)
    |> Repo.update()
  end

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
