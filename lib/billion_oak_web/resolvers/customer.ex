defmodule BillionOakWeb.Resolvers.Customer do
  def list_companies(_parent, _args, _resolution) do
    {:ok, BillionOak.Customer.list_companies()}
  end

  def get_customer_account_excerpt(_parent, %{rid: rid}, _resolution) do
    BillionOak.Customer.get_account_excerpt(rid)
  end
end
