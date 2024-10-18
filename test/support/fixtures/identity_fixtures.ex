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

  @doc """
  Generate a invitation_code.
  """
  def invitation_code_fixture(attrs \\ %{}) do
    {:ok, invitation_code} =
      attrs
      |> Enum.into(%{
        expires_at: ~U[2024-10-16 21:21:00Z],
        invitee_company_account_rid: "some invitee_company_account_rid",
        inviter_id: "some inviter_id",
        organization_id: "some organization_id",
        value: "some value"
      })
      |> BillionOak.Identity.create_invitation_code()

    invitation_code
  end
end
