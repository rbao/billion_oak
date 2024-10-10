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
        alias: "some alias"
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
        org_structure_last_ingested_at: ~U[2024-10-07 23:37:00Z]
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
        number: "some number",
        sponsor_number: "some sponsor_number",
        enroller_number: "some enroller_number",
        phone1: "some phone1",
        phone2: "some phone2",
        state: "some state",
        status: :active
      })
      |> BillionOak.Customer.create_account()

    account
  end

  @doc """
  Generate a ingestion.
  """
  def ingestion_fixture(attrs \\ %{}) do
    organization = organization_fixture()

    {:ok, ingestion} =
      attrs
      |> Enum.into(%{
        organization_id: organization.id,
        company_id: organization.company_id,
        format: "some format",
        schema: "some schema",
        sha256: "some sha256",
        size_bytes: "some size_bytes",
        status: "some status",
        url: "some url"
      })
      |> BillionOak.Customer.create_ingestion()

    ingestion
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
