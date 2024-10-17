defmodule BillionOak do
  use OK.Pipe
  import BillionOak.Policy
  alias BillionOak.{Identity, External, Request, Response}
  alias BillionOak.Identity.{Client, User}

  @moduledoc """
  BillionOak keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def get_company_account_excerpt(%Request{} = req) do
    req
    |> expand()
    |> authorize(:get_company_account_excerpt)
    ~> Request.take(:identifier, [:organization_id,:rid])
    ~>> External.get_company_account_excerpt()
    |> to_response()
  end

  defp expand(%Request{} = req) do
    req
    |> Request.put(:client_id, Client.bare_id(req.client_id))
    |> put_client()
    |> put_organization_id()
    |> Request.put(:requester_id, User.bare_id(req.requester_id))
    |> put_requester()
    |> put_role()
  end

  defp put_client(%Request{client_id: nil} = req), do: req

  defp put_client(%Request{client_id: client_id} = req) do
    case Identity.get_client(client_id) do
      {:ok, client} -> %{req | _client_: client}
      {:error, :not_found} -> req
    end
  end

  defp put_organization_id(%Request{_client_: nil} = req), do: req

  defp put_organization_id(%Request{_client_: client} = req) do
    %{req | _organization_id_: client.organization_id}
  end

  defp put_requester(%Request{requester_id: nil} = req), do: req
  defp put_requester(%Request{requester_id: "guest_" <> _} = req), do: req

  defp put_requester(%Request{requester_id: requester_id} = req) do
    case Identity.get_user(requester_id) do
      {:ok, requester} -> %{req | _requester_: requester}
      {:error, :not_found} -> req
    end
  end

  defp put_role(%Request{_requester_: nil, _role_: nil} = req), do: %{req | _role_: "guest"}

  defp put_role(%Request{_requester_: requester, _role_: nil} = req),
    do: %{req | _role_: requester.role}

  defp put_role(%Request{} = req), do: req

  defp to_response({:ok, data}), do: {:ok, %Response{data: data}}
  defp to_response(other), do: other
end
