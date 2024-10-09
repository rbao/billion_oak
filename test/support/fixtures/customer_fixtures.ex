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
        name: "some name"
      })
      |> BillionOak.Customer.create_company()

    company
  end

  @doc """
  Generate a organization.
  """
  def organization_fixture(attrs \\ %{}) do
    {:ok, organization} =
      attrs
      |> Enum.into(%{
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
    {:ok, account} =
      attrs
      |> Enum.into(%{
        city: "some city",
        country_code: "some country_code",
        enrolled_at: ~U[2024-10-08 01:05:00Z],
        name: "some name",
        number: "some number",
        phone1: "some phone1",
        phone2: "some phone2",
        state: "some state",
        status: "some status"
      })
      |> BillionOak.Customer.create_account()

    account
  end

  @doc """
  Generate a ingestion.
  """
  def ingestion_fixture(attrs \\ %{}) do
    {:ok, ingestion} =
      attrs
      |> Enum.into(%{
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
end
