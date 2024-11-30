defmodule BillionOakWeb.WelcomeController do
  use BillionOakWeb, :controller

  def show(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{welcome: "hello world"})
  end
end
