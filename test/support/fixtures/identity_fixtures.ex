defmodule BillionOak.IdentityFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BillionOak.Identity` context.
  """

  @doc """
  Generate a client.
  """
  def client_fixture(attrs \\ %{}) do
    {:ok, client} =
      attrs
      |> Enum.into(%{
        name: "some name",
        organization_id: "some organization_id"
      })
      |> BillionOak.Identity.create_client()

    client
  end

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        company_account_id: "some company_account_id",
        company_id: "some company_id",
        first_name: "some first_name",
        last_name: "some last_name",
        organization_id: "some organization_id"
      })
      |> BillionOak.Identity.create_user()

    user
  end
end
