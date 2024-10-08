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
end
