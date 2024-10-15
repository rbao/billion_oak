defmodule BillionOak.CustomerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BillionOak.Customer` context.
  """

  @doc """
  Generate a company.
  """
  def company_fixture(attrs \\ %{}) do
    {:ok, company} =
      attrs
      |> Enum.into(%{
        name: "some name",
        handle: "some handle"
      })
      |> BillionOak.Customer.create_company()

    company
  end

  @doc """
  Generate a organization.
  """
  def organization_fixture(attrs \\ %{}) do
    company = company_fixture()

    {:ok, organization} =
      attrs
      |> Enum.into(%{
        company_id: company.id,
        name: "some name",
        handle: "some handle",
        root_account_rid: "some root_account_rid",
        last_ingested_at: ~U[2024-10-07 23:37:00Z]
      })
      |> BillionOak.Customer.create_organization()

    organization
  end

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    organization = organization_fixture()

    {:ok, account} =
      attrs
      |> Enum.into(%{
        organization_id: organization.id,
        company_id: organization.company_id,
        city: "some city",
        country_code: "some country_code",
        enrolled_at: ~U[2024-10-08 01:05:00Z],
        name: "some name",
        rid: "some rid",
        sponsor_rid: "some sponsor_rid",
        enroller_rid: "some enroller_rid",
        phone1: "some phone1",
        phone2: "some phone2",
        state: "some state",
        status: :active
      })
      |> BillionOak.Customer.create_account()

    account
  end

  @doc """
  Generate a account_record.
  """
  def account_record_fixture(attrs \\ %{}) do
    account = account_fixture()

    {:ok, account_record} =
      attrs
      |> Enum.into(%{
        account_id: account.id,
        company_id: account.company_id,
        organization_id: account.organization_id,
        content: %{},
        dedupe_id: "some dedupe_id"
      })
      |> BillionOak.Customer.create_account_record()

    account_record
  end
end
