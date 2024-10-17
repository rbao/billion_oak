defmodule BillionOakWeb.Resolvers.Customer do
  def list_companies(_parent, _args, _resolution) do
    {:ok, BillionOak.Customer.list_companies()}
  end
end
