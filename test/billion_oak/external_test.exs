defmodule BillionOak.ExternalTest do
  use BillionOak.DataCase
  import BillionOak.Factory

  alias BillionOak.External
  alias BillionOak.External.{Company, CompanyAccount, CompanyRecord}

  test "all companies can be retrieved at once" do
    assert {:ok, companies} = External.list_companies()
    assert length(companies) == 1
  end

  describe "retrieving a company" do
    test "returns the company with the given handle if exists" do
      company = insert(:company)
      assert {:ok, %Company{}} = External.get_company(company.handle)
    end

    test "returns an error if no company is found with the given handle" do
      assert {:error, :not_found} = External.get_company("some handle")
    end
  end

  describe "creating a company" do
    test "returns the created company if the given input is valid" do
      input = %{name: "some name", handle: "some handle"}

      assert {:ok, %Company{} = company} = External.create_company(input)
      assert company.name == "some name"
    end

    test "returns an error if the given input is invalid" do
      assert {:error, %Ecto.Changeset{}} = External.create_company(%{})
    end
  end

  describe "updating a company" do
    test "returns the updated company if the given input is valid" do
      company = insert(:company)
      input = %{name: "some updated name"}

      assert {:ok, %Company{} = company} = External.update_company(company, input)
      assert company.name == "some updated name"
    end

    test "returns an error if the given input is invalid" do
      company = insert(:company)
      assert {:error, %Ecto.Changeset{}} = External.update_company(company, %{name: nil})
    end
  end

  test "a company can be deleted" do
    company = insert(:company)
    assert {:ok, %Company{}} = External.delete_company(company)
    assert {:error, :not_found} = External.get_company(company.handle)
  end

  test "all company accounts can be retrieved at once" do
    insert(:company_account)
    assert {:ok, accounts} = External.list_company_accounts()
    assert length(accounts) == 1
  end

  test "total number of company acounts can be retrieved" do
    insert_list(3, :company_account)
    assert {:ok, 3} = External.count_company_accounts()
  end

  describe "retrieving a company account" do
    test "returns the company account with the given rid in the given organization if exists" do
      account = insert(:company_account)

      assert {:ok, %CompanyAccount{}} =
               External.get_company_account(
                 organization_id: account.organization_id,
                 rid: account.rid
               )
    end

    test "returns an error if no company account is found matching the input" do
      assert {:error, :not_found} = External.get_company_account(organization_id: "invalid")
    end
  end

  describe "creating a company account" do
    test "returns the created company account if the given input is valid" do
      input = params_for(:company_account)

      assert {:ok, %CompanyAccount{} = account} = External.create_company_account(input)
      assert account.company_id == input.company_id
      assert account.organization_id == input.organization_id
      assert account.name == input.name
      assert account.status == input.status
      assert account.rid == input.rid
      assert account.country_code == input.country_code
    end

    test "returns an error if the given input is invalid" do
      assert {:error, %Ecto.Changeset{}} = External.create_company_account(%{})
    end
  end

  describe "updating a company account" do
    test "returns the updated company account if the given input is valid" do
      account = insert(:company_account)
      input = %{name: "some updated name"}

      assert {:ok, %CompanyAccount{} = account} = External.update_company_account(account, input)
      assert account.name == "some updated name"
    end

    test "returns an error if the given input is invalid" do
      account = insert(:company_account)
      assert {:error, %Ecto.Changeset{}} = External.update_company_account(account, %{name: nil})
    end
  end

  test "a company account can be deleted" do
    account = insert(:company_account)
    assert {:ok, %CompanyAccount{}} = External.delete_company_account(account)
    assert {:error, :not_found} = External.get_company_account(id: account.id)
  end

  test "all company records can be retrieved at once" do
    insert(:company_record)
    assert {:ok, records} = External.list_company_records()
    assert length(records) == 1
  end

  describe "retrieving a company record" do
    test "returns the company record with the given id if exists" do
      record = insert(:company_record)
      assert {:ok, %CompanyRecord{}} = External.get_company_record(record.id)
    end

    test "returns an error if no company record is found with the given id" do
      assert {:error, :not_found} = External.get_company_record("invalid")
    end
  end

  describe "creating a company record" do
    test "returns the created company record if the given input is valid" do
      input = params_for(:company_record)
      assert {:ok, %CompanyRecord{}} = External.create_company_record(input)
    end

    test "returns an error if the given input is invalid" do
      assert {:error, %Ecto.Changeset{}} = External.create_company_record(%{})
    end
  end

  describe "updating a company record" do
    test "returns the updated company record if the given input is valid" do
      record = insert(:company_record)
      input = %{content: %{}}

      assert {:ok, %CompanyRecord{} = record} = External.update_company_record(record, input)
      assert record.content == %{}
    end

    test "returns an error if the given input is invalid" do
      record = insert(:company_record)
      assert {:error, %Ecto.Changeset{}} = External.update_company_record(record, %{content: nil})
    end
  end

  test "deleting a company record" do
    record = insert(:company_record)
    assert {:ok, %CompanyRecord{}} = External.delete_company_record(record)
    assert {:error, :not_found} = External.get_company_record(record.id)
  end

  test "multiple company account and record can be ingested idempotently for an organization" do
    n = 3

    data =
      for _ <- 1..n do
        account_input = params_for(:company_account)
        record_input = params_for(:company_record)

        %{
          account: account_input,
          record: Map.put(record_input, :company_account_rid, account_input.rid)
        }
      end

    External.ingest_data(data)
    assert {:ok, 3} = External.count_company_accounts()

    External.ingest_data(data)
    assert {:ok, 3} = External.count_company_accounts()
  end
end
