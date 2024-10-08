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
end
