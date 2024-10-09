defmodule BillionOak.CustomerTest do
  use BillionOak.DataCase

  alias BillionOak.Customer

  describe "companies" do
    alias BillionOak.Customer.Company

    import BillionOak.CustomerFixtures

    @invalid_attrs %{name: nil}

    test "list_companies/0 returns all companies" do
      company = company_fixture()
      assert Customer.list_companies() == [company]
    end

    test "get_company!/1 returns the company with given id" do
      company = company_fixture()
      assert Customer.get_company!(company.id) == company
    end

    test "create_company/1 with valid data creates a company" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Company{} = company} = Customer.create_company(valid_attrs)
      assert company.name == "some name"
    end

    test "create_company/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customer.create_company(@invalid_attrs)
    end

    test "update_company/2 with valid data updates the company" do
      company = company_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Company{} = company} = Customer.update_company(company, update_attrs)
      assert company.name == "some updated name"
    end

    test "update_company/2 with invalid data returns error changeset" do
      company = company_fixture()
      assert {:error, %Ecto.Changeset{}} = Customer.update_company(company, @invalid_attrs)
      assert company == Customer.get_company!(company.id)
    end

    test "delete_company/1 deletes the company" do
      company = company_fixture()
      assert {:ok, %Company{}} = Customer.delete_company(company)
      assert_raise Ecto.NoResultsError, fn -> Customer.get_company!(company.id) end
    end

    test "change_company/1 returns a company changeset" do
      company = company_fixture()
      assert %Ecto.Changeset{} = Customer.change_company(company)
    end
  end

  describe "organizations" do
    alias BillionOak.Customer.Organization

    import BillionOak.CustomerFixtures

    @invalid_attrs %{name: nil, org_structure_last_ingested_at: nil}

    test "list_organizations/0 returns all organizations" do
      organization = organization_fixture()
      assert Customer.list_organizations() == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert Customer.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization" do
      valid_attrs = %{name: "some name", org_structure_last_ingested_at: ~U[2024-10-07 23:37:00Z]}

      assert {:ok, %Organization{} = organization} = Customer.create_organization(valid_attrs)
      assert organization.name == "some name"
      assert organization.org_structure_last_ingested_at == ~U[2024-10-07 23:37:00Z]
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customer.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = organization_fixture()
      update_attrs = %{name: "some updated name", org_structure_last_ingested_at: ~U[2024-10-08 23:37:00Z]}

      assert {:ok, %Organization{} = organization} = Customer.update_organization(organization, update_attrs)
      assert organization.name == "some updated name"
      assert organization.org_structure_last_ingested_at == ~U[2024-10-08 23:37:00Z]
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = organization_fixture()
      assert {:error, %Ecto.Changeset{}} = Customer.update_organization(organization, @invalid_attrs)
      assert organization == Customer.get_organization!(organization.id)
    end

    test "delete_organization/1 deletes the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{}} = Customer.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> Customer.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = Customer.change_organization(organization)
    end
  end

  describe "accounts" do
    alias BillionOak.Customer.Account

    import BillionOak.CustomerFixtures

    @invalid_attrs %{name: nil, status: nil, state: nil, number: nil, country_code: nil, phone1: nil, phone2: nil, city: nil, enrolled_at: nil}

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Customer.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Customer.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      valid_attrs = %{name: "some name", status: "some status", state: "some state", number: "some number", country_code: "some country_code", phone1: "some phone1", phone2: "some phone2", city: "some city", enrolled_at: ~U[2024-10-08 01:05:00Z]}

      assert {:ok, %Account{} = account} = Customer.create_account(valid_attrs)
      assert account.name == "some name"
      assert account.status == "some status"
      assert account.state == "some state"
      assert account.number == "some number"
      assert account.country_code == "some country_code"
      assert account.phone1 == "some phone1"
      assert account.phone2 == "some phone2"
      assert account.city == "some city"
      assert account.enrolled_at == ~U[2024-10-08 01:05:00Z]
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customer.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      update_attrs = %{name: "some updated name", status: "some updated status", state: "some updated state", number: "some updated number", country_code: "some updated country_code", phone1: "some updated phone1", phone2: "some updated phone2", city: "some updated city", enrolled_at: ~U[2024-10-09 01:05:00Z]}

      assert {:ok, %Account{} = account} = Customer.update_account(account, update_attrs)
      assert account.name == "some updated name"
      assert account.status == "some updated status"
      assert account.state == "some updated state"
      assert account.number == "some updated number"
      assert account.country_code == "some updated country_code"
      assert account.phone1 == "some updated phone1"
      assert account.phone2 == "some updated phone2"
      assert account.city == "some updated city"
      assert account.enrolled_at == ~U[2024-10-09 01:05:00Z]
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Customer.update_account(account, @invalid_attrs)
      assert account == Customer.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Customer.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Customer.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Customer.change_account(account)
    end
  end

  describe "ingestions" do
    alias BillionOak.Customer.Ingestion

    import BillionOak.CustomerFixtures

    @invalid_attrs %{status: nil, format: nil, url: nil, schema: nil, sha256: nil, size_bytes: nil}

    test "list_ingestions/0 returns all ingestions" do
      ingestion = ingestion_fixture()
      assert Customer.list_ingestions() == [ingestion]
    end

    test "get_ingestion!/1 returns the ingestion with given id" do
      ingestion = ingestion_fixture()
      assert Customer.get_ingestion!(ingestion.id) == ingestion
    end

    test "create_ingestion/1 with valid data creates a ingestion" do
      valid_attrs = %{status: "some status", format: "some format", url: "some url", schema: "some schema", sha256: "some sha256", size_bytes: "some size_bytes"}

      assert {:ok, %Ingestion{} = ingestion} = Customer.create_ingestion(valid_attrs)
      assert ingestion.status == "some status"
      assert ingestion.format == "some format"
      assert ingestion.url == "some url"
      assert ingestion.schema == "some schema"
      assert ingestion.sha256 == "some sha256"
      assert ingestion.size_bytes == "some size_bytes"
    end

    test "create_ingestion/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customer.create_ingestion(@invalid_attrs)
    end

    test "update_ingestion/2 with valid data updates the ingestion" do
      ingestion = ingestion_fixture()
      update_attrs = %{status: "some updated status", format: "some updated format", url: "some updated url", schema: "some updated schema", sha256: "some updated sha256", size_bytes: "some updated size_bytes"}

      assert {:ok, %Ingestion{} = ingestion} = Customer.update_ingestion(ingestion, update_attrs)
      assert ingestion.status == "some updated status"
      assert ingestion.format == "some updated format"
      assert ingestion.url == "some updated url"
      assert ingestion.schema == "some updated schema"
      assert ingestion.sha256 == "some updated sha256"
      assert ingestion.size_bytes == "some updated size_bytes"
    end

    test "update_ingestion/2 with invalid data returns error changeset" do
      ingestion = ingestion_fixture()
      assert {:error, %Ecto.Changeset{}} = Customer.update_ingestion(ingestion, @invalid_attrs)
      assert ingestion == Customer.get_ingestion!(ingestion.id)
    end

    test "delete_ingestion/1 deletes the ingestion" do
      ingestion = ingestion_fixture()
      assert {:ok, %Ingestion{}} = Customer.delete_ingestion(ingestion)
      assert_raise Ecto.NoResultsError, fn -> Customer.get_ingestion!(ingestion.id) end
    end

    test "change_ingestion/1 returns a ingestion changeset" do
      ingestion = ingestion_fixture()
      assert %Ecto.Changeset{} = Customer.change_ingestion(ingestion)
    end
  end
end
