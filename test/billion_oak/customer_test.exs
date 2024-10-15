defmodule BillionOak.CustomerTest do
  use BillionOak.DataCase
  import BillionOak.Factory
  alias BillionOak.Customer

  describe "companies" do
    alias BillionOak.Customer.Company

    import BillionOak.CustomerFixtures

    @invalid_attrs %{name: nil}

    test "list_companies/0 returns all companies" do
      assert length(Customer.list_companies()) == 1
    end

    test "get_company/1 returns the company with given handle" do
      company = insert(:company)
      assert {:ok, %Company{}} = Customer.get_company(company.handle)
    end

    test "get_company/1 returns error when company not found" do
      assert {:error, :not_found} = Customer.get_company("some handle")
    end

    test "create_company/1 with valid data creates a company" do
      valid_attrs = %{name: "some name", handle: "some handle"}

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
    end

    test "delete_company/1 deletes the company" do
      company = company_fixture()
      assert {:ok, %Company{}} = Customer.delete_company(company)
      assert {:error, :not_found} = Customer.get_company("some handle")
    end
  end

  describe "organizations" do
    alias BillionOak.Customer.Organization

    import BillionOak.CustomerFixtures

    @invalid_attrs %{name: nil}

    test "list_organizations/0 returns all organizations" do
      assert length(Customer.list_organizations()) == 1
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = insert(:organization)
      assert {:ok, %Organization{}} = Customer.get_organization(organization.id)
    end

    test "get_organization/1 returns error when organization not found" do
      assert {:error, :not_found} = Customer.get_organization("some id")
    end

    test "create_organization/1 with valid data creates a organization" do
      company = insert(:company)
      valid_attrs = params_for(:organization, company_id: company.id)

      assert {:ok, %Organization{} = organization} = Customer.create_organization(valid_attrs)
      assert organization.name == valid_attrs.name
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customer.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = insert(:organization)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Organization{} = organization} =
               Customer.update_organization(organization, update_attrs)

      assert organization.name == update_attrs.name
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = insert(:organization)

      assert {:error, %Ecto.Changeset{}} =
               Customer.update_organization(organization, @invalid_attrs)
    end

    test "delete_organization/1 deletes the organization" do
      organization = insert(:organization)
      assert {:ok, %Organization{}} = Customer.delete_organization(organization)
      assert {:error, :not_found} = Customer.get_organization(organization.id)
    end
  end

  describe "accounts" do
    alias BillionOak.Customer.Account

    import BillionOak.CustomerFixtures

    @invalid_attrs %{name: nil}

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Customer.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Customer.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      organization = organization_fixture()

      valid_attrs = %{
        enroller_rid: "some enroller_rid",
        sponsor_rid: "some sponsor_rid",
        organization_id: organization.id,
        company_id: organization.company_id,
        name: "some name",
        status: :active,
        state: "some state",
        rid: "some rid",
        country_code: "some country_code",
        phone1: "some phone1",
        phone2: "some phone2",
        city: "some city",
        enrolled_at: ~U[2024-10-08 01:05:00Z]
      }

      assert {:ok, %Account{} = account} = Customer.create_account(valid_attrs)
      assert account.name == "some name"
      assert account.status == :active
      assert account.state == "some state"
      assert account.rid == "some rid"
      assert account.country_code == "some country_code"
      assert account.phone1 == "some phone1"
      assert account.phone2 == "some phone2"
      assert account.city == "some city"
      assert account.enrolled_at == ~U[2024-10-08 01:05:00Z]
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customer.create_account(@invalid_attrs)
    end

    @tag :focus
    test "ingest_account_records/2" do
      company = insert(:company)
      organization = insert(:organization, company_id: company.id)
      n = 3

      data =
        for _ <- 1..n do
          account_attrs = params_for(:account)
          record_attrs = params_for(:account_record)

          %{
            account: account_attrs,
            record: Map.put(record_attrs, :account_rid, account_attrs.rid)
          }
        end

      Customer.ingest_account_records(data, organization)
      assert Customer.count_accounts() == 3

      Customer.ingest_account_records(data, organization)
      assert Customer.count_accounts() == 3
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()

      update_attrs = %{
        name: "some updated name",
        status: :inactive,
        state: "some updated state",
        rid: "some updated rid",
        country_code: "some updated country_code",
        phone1: "some updated phone1",
        phone2: "some updated phone2",
        city: "some updated city",
        enrolled_at: ~U[2024-10-09 01:05:00Z]
      }

      assert {:ok, %Account{} = account} = Customer.update_account(account, update_attrs)
      assert account.name == "some updated name"
      assert account.status == :inactive
      assert account.state == "some updated state"
      assert account.rid == "some updated rid"
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

  describe "account_records" do
    alias BillionOak.Customer.AccountRecord

    import BillionOak.CustomerFixtures

    @invalid_attrs %{dedupe_id: nil, content: nil}

    test "list_account_records/0 returns all account_records" do
      account_record = account_record_fixture()
      assert Customer.list_account_records() == [account_record]
    end

    test "get_account_record!/1 returns the account_record with given id" do
      account_record = account_record_fixture()
      assert Customer.get_account_record!(account_record.id) == account_record
    end

    test "create_account_record/1 with valid data creates a account_record" do
      account = account_fixture()

      valid_attrs = %{
        account_id: account.id,
        company_id: account.company_id,
        organization_id: account.organization_id,
        dedupe_id: "some dedupe_id",
        content: %{}
      }

      assert {:ok, %AccountRecord{} = account_record} =
               Customer.create_account_record(valid_attrs)

      assert account_record.content == %{}
    end

    test "create_account_record/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customer.create_account_record(@invalid_attrs)
    end

    test "update_account_record/2 with valid data updates the account_record" do
      account_record = account_record_fixture()
      update_attrs = %{dedupe_id: "some updated dedupe_id", content: %{}}

      assert {:ok, %AccountRecord{} = account_record} =
               Customer.update_account_record(account_record, update_attrs)

      assert account_record.dedupe_id == "some updated dedupe_id"
      assert account_record.content == %{}
    end

    test "update_account_record/2 with invalid data returns error changeset" do
      account_record = account_record_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Customer.update_account_record(account_record, @invalid_attrs)

      assert account_record == Customer.get_account_record!(account_record.id)
    end

    test "delete_account_record/1 deletes the account_record" do
      account_record = account_record_fixture()
      assert {:ok, %AccountRecord{}} = Customer.delete_account_record(account_record)
      assert_raise Ecto.NoResultsError, fn -> Customer.get_account_record!(account_record.id) end
    end

    test "change_account_record/1 returns a account_record changeset" do
      account_record = account_record_fixture()
      assert %Ecto.Changeset{} = Customer.change_account_record(account_record)
    end
  end
end
