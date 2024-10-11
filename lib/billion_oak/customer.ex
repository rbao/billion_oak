defmodule BillionOak.Customer do
  @moduledoc """
  The Customer context.
  """

  import Ecto.Query, warn: false
  alias BillionOak.Repo

  alias BillionOak.Customer.Company

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

  Raises `Ecto.NoResultsError` if the Company does not exist.

  ## Examples

      iex> get_company!(123)
      %Company{}

      iex> get_company!(456)
      ** (Ecto.NoResultsError)

  """
  def get_company!(alias), do: Repo.get_by!(Company, alias: alias)

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

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

      iex> get_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(id), do: Repo.get!(Organization, id)

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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{data: %Organization{}}

  """
  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
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

  alias BillionOak.Customer.Ingestion

  @doc """
  Returns the list of ingestions.

  ## Examples

      iex> list_ingestions()
      [%Ingestion{}, ...]

  """
  def list_ingestions do
    Repo.all(Ingestion)
  end

  @doc """
  Gets a single ingestion.

  Raises `Ecto.NoResultsError` if the Ingestion does not exist.

  ## Examples

      iex> get_ingestion!(123)
      %Ingestion{}

      iex> get_ingestion!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ingestion!(id), do: Repo.get!(Ingestion, id)

  @doc """
  Creates a ingestion.

  ## Examples

      iex> create_ingestion(%{field: value})
      {:ok, %Ingestion{}}

      iex> create_ingestion(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ingestion(attrs \\ %{}) do
    %Ingestion{}
    |> Ingestion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ingestion.

  ## Examples

      iex> update_ingestion(ingestion, %{field: new_value})
      {:ok, %Ingestion{}}

      iex> update_ingestion(ingestion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ingestion(%Ingestion{} = ingestion, attrs) do
    ingestion
    |> Ingestion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ingestion.

  ## Examples

      iex> delete_ingestion(ingestion)
      {:ok, %Ingestion{}}

      iex> delete_ingestion(ingestion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ingestion(%Ingestion{} = ingestion) do
    Repo.delete(ingestion)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ingestion changes.

  ## Examples

      iex> change_ingestion(ingestion)
      %Ecto.Changeset{data: %Ingestion{}}

  """
  def change_ingestion(%Ingestion{} = ingestion, attrs \\ %{}) do
    Ingestion.changeset(ingestion, attrs)
  end

  alias BillionOak.Customer.AccountRecord

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
