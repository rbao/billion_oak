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
        organization_id: "some organization_id",
      })
      |> BillionOak.Identity.create_client()

    client
  end
end
