defmodule BillionOakWeb.TokenController do
  use BillionOakWeb, :controller

  import BillionOak.Normalization
  alias BillionOakWeb.Authentication

  def create(conn, params) do
    with {:ok, req} <- to_auth_req(conn, params),
         {:ok, token} <- Authentication.create_access_token(req) do
      conn
      |> put_status(:ok)
      |> json(%{access_token: token, token_type: "bearer"})
    else
      {:error, detail} ->
        conn
        |> put_status(:bad_request)
        |> json(detail)
        |> halt()
    end
  end

  defp to_auth_req(conn, params) do
    with ["Basic " <> encoded] <- get_req_header(conn, "authorization"),
         {:ok, decoded} <- Base.decode64(encoded),
         [client_id, client_secret] <- String.split(decoded, ":", parts: 2) do
      params =
        params
        |> atomize_keys([:grant_type, :username, :password, :refresh_token, :scope])
        |> Map.merge(%{client_id: client_id, client_secret: client_secret})

      {:ok, params}
    else
      _ -> {:error, %{error: :invalid_client}}
    end
  end
end
