defmodule BillionOak.ExternalTest do
  use BillionOak.DataCase
  import BillionOak.Factory
  alias BillionOak.External

  describe "companies" do
    alias BillionOak.External.Company
    @invalid_attrs %{name: nil}

    test "list_companies/0 returns all companies" do
      assert length(External.list_companies()) == 1
    end

    test "get_company/1 returns the company with given handle" do
      company = insert(:company)
      assert {:ok, %Company{}} = External.get_company(company.handle)
    end

    test "get_company/1 returns error when company not found" do
      assert {:error, :not_found} = External.get_company("some handle")
    end

    test "create_company/1 with valid data creates a company" do
      valid_attrs = %{name: "some name", handle: "some handle"}

      assert {:ok, %Company{} = company} = External.create_company(valid_attrs)
      assert company.name == "some name"
    end

    test "create_company/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = External.create_company(@invalid_attrs)
    end

    test "update_company/2 with valid data updates the company" do
      company = insert(:company)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Company{} = company} = External.update_company(company, update_attrs)
      assert company.name == "some updated name"
    end

    test "update_company/2 with invalid data returns error changeset" do
      company = insert(:company)
      assert {:error, %Ecto.Changeset{}} = External.update_company(company, @invalid_attrs)
    end

    test "delete_company/1 deletes the company" do
      company = insert(:company)
      assert {:ok, %Company{}} = External.delete_company(company)
      assert {:error, :not_found} = External.get_company(company.handle)
    end
  end

  describe "organizations" do
    alias BillionOak.External.Organization
    @invalid_attrs %{name: nil}

    test "list_organizations/0 returns all organizations" do
      assert length(External.list_organizations()) == 1
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = insert(:organization)
      assert {:ok, %Organization{}} = External.get_organization(organization.id)
    end

    test "get_organization/1 returns error when organization not found" do
      assert {:error, :not_found} = External.get_organization("some id")
    end

    test "create_organization/1 with valid data creates a organization" do
      company = insert(:company)
      valid_attrs = params_for(:organization, company_id: company.id)

      assert {:ok, %Organization{} = organization} = External.create_organization(valid_attrs)
      assert organization.name == valid_attrs.name
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = External.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = insert(:organization)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Organization{} = organization} =
               External.update_organization(organization, update_attrs)

      assert organization.name == update_attrs.name
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = insert(:organization)

      assert {:error, %Ecto.Changeset{}} =
               External.update_organization(organization, @invalid_attrs)
    end

    test "delete_organization/1 deletes the organization" do
      organization = insert(:organization)
      assert {:ok, %Organization{}} = External.delete_organization(organization)
      assert {:error, :not_found} = External.get_organization(organization.id)
    end
  end

  describe "accounts" do
    alias BillionOak.External.CompanyAccount
    @invalid_attrs %{name: nil}

    test "list_company_accounts/0 returns all accounts" do
      account = insert(:company_account)
      assert External.list_company_accounts() == [account]
    end

    test "get_company_account!/1 returns the account with given id" do
      account = insert(:company_account)
      assert {:ok, %CompanyAccount{}} = External.get_company_account(account.id)
    end

    test "create_company_account/1 with valid data creates a account" do
      organization = insert(:organization)

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

      assert {:ok, %CompanyAccount{} = account} = External.create_company_account(valid_attrs)
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

    test "create_company_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = External.create_company_account(@invalid_attrs)
    end

    test "update_company_account/2 with valid data updates the account" do
      account = insert(:company_account)

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

      assert {:ok, %CompanyAccount{} = account} =
               External.update_company_account(account, update_attrs)

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

    test "update_company_account/2 with invalid data returns error changeset" do
      account = insert(:company_account)

      assert {:error, %Ecto.Changeset{}} =
               External.update_company_account(account, @invalid_attrs)
    end

    test "delete_company_account/1 deletes the account" do
      account = insert(:company_account)
      assert {:ok, %CompanyAccount{}} = External.delete_company_account(account)
      assert {:error, :not_found} = External.get_company_account(account.id)
    end
  end

  describe "company_records" do
    alias BillionOak.External.CompanyRecord
    @invalid_attrs %{dedupe_id: nil, content: nil}

    test "list_company_records/0 returns all company_records" do
      company_record = insert(:company_record)
      assert External.list_company_records() == [company_record]
    end

    test "get_company_record!/1 returns the company_record with given id" do
      company_record = insert(:company_record)
      assert {:ok, %CompanyRecord{}} = External.get_company_record(company_record.id)
    end

    test "create_company_record/1 with valid data creates a company_record" do
      account = insert(:company_account)

      valid_attrs = %{
        company_account_id: account.id,
        company_id: account.company_id,
        organization_id: account.organization_id,
        dedupe_id: "some dedupe_id",
        content: %{}
      }

      assert {:ok, %CompanyRecord{}} = External.create_company_record(valid_attrs)
    end

    test "create_company_record/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = External.create_company_record(@invalid_attrs)
    end

    test "ingest_company_records/2" do
      company = insert(:company)
      organization = insert(:organization, company_id: company.id)
      n = 3

      data =
        for _ <- 1..n do
          account_attrs = params_for(:company_account)
          record_attrs = params_for(:company_record)

          %{
            account: account_attrs,
            record: Map.put(record_attrs, :account_rid, account_attrs.rid)
          }
        end

      External.ingest_company_records(data, organization)
      assert External.count_company_accounts() == 3

      External.ingest_company_records(data, organization)
      assert External.count_company_accounts() == 3
    end

    test "update_company_record/2 with valid data updates the company_record" do
      company_record = insert(:company_record)
      update_attrs = %{content: %{}}

      assert {:ok, %CompanyRecord{} = company_record} =
               External.update_company_record(company_record, update_attrs)

      assert company_record.content == %{}
    end

    test "update_company_record/2 with invalid data returns error changeset" do
      company_record = insert(:company_record)

      assert {:error, %Ecto.Changeset{}} =
               External.update_company_record(company_record, @invalid_attrs)
    end

    test "delete_company_company_record/1 deletes the company_record" do
      company_record = insert(:company_record)
      assert {:ok, %CompanyRecord{}} = External.delete_company_record(company_record)
      assert {:error, :not_found} = External.get_company_record(company_record.id)
    end
  end
end
