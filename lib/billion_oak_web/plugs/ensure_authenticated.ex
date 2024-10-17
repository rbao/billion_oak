defmodule BillionOakWeb.Plugs.EnsureAuthenticated do
  import Plug.Conn

  def init(_), do: []

  def call(%{assigns: assigns} = conn, _) do
    if assigns[:client_id] do
      conn
    else
      halt(send_resp(conn, 401, ""))
    end
  end
end
