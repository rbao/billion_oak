defmodule BillionOak do
  alias BillionOak.{External, Request}

  @moduledoc """
  BillionOak keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  # def get_External_account_excerpt(%Request{} = req) do
  #   req
  #   |> expand()
  #   |> authorize(:get_External_account_excerpt)
  #   ~> Request.get(:identifier, "rid")
  #   ~>> External.get_company_account_excerpt()
  #   |> to_response()
  # end
end
