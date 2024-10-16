defmodule BillionOakWeb.TokenController do
  use BillionOakWeb, :controller

  alias BillionOakWeb.Authentication

  def create(conn, params) do
    case Authentication.create_access_token(params) do
      {:ok, token} ->
        conn
        |> put_status(:ok)
        |> json(token)

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(reason)

      other ->
        other
    end
  end
end
