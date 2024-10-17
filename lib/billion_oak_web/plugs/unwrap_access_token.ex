defmodule BillionOakWeb.Plugs.UnwrapAccessToken do
  require Logger
  import Plug.Conn
  alias BillionOakWeb.JWT

  def init(_), do: []

  def call(conn, _) do
    with ["Bearer " <> access_token] <- get_req_header(conn, "authorization"),
         {:ok, claims} <- JWT.verify(access_token) do
      conn
      |> assign(:client_id, claims["aud"])
      |> assign(:requester_id, claims["sub"])
      |> put_graphql_context()
    else
      _ ->
        conn
        |> assign(:client_id, nil)
        |> assign(:requester_id, nil)
        |> put_graphql_context()
    end
  end

  defp put_graphql_context(conn) do
    Absinthe.Plug.put_options(conn, context: conn.assigns)
  end
end
