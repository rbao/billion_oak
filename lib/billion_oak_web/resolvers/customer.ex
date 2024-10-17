defmodule BillionOakWeb.Resolvers.External do
  def list_companies(_parent, _args, _resolution) do
    {:ok, BillionOak.External.list_companies()}
  end

  def get_company_account_excerpt(_parent, %{rid: rid}, _resolution) do
    BillionOak.External.get_company_account_excerpt(rid)
  end
end
