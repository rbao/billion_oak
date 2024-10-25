defmodule BillionOakWeb.Schema.DataSource do
  use OK.Pipe
  import BillionOakWeb.Schema.Helper

  def data do
    Dataloader.KV.new(&query/2)
  end

  def query({:company_account, _, context}, parents) do
    {result, pending_map} =
      Enum.reduce(parents, {%{}, %{}}, fn parent, {loaded, pending_map} ->
        case parent.company_account do
          %{id: id} = company_account ->
            {Map.put(loaded, id, company_account), pending_map}

          _ ->
            {loaded, Map.update(pending_map, parent.company_account_id, [parent], &[parent | &1])}
        end
      end)

    subresult =
      context
      |> build_request(%{ids: Map.keys(pending_map)}, :query)
      |> BillionOak.list_company_accounts()
      ~> unwrap_response(:query)

    case subresult do
      {:ok, company_accounts} ->
        Enum.reduce(company_accounts, result, fn company_account, acc ->
          Enum.reduce(Map.get(pending_map, company_account.id, []), acc, fn parent, inner_acc ->
            Map.put(inner_acc, parent, company_account)
          end)
        end)

      other ->
        Enum.reduce(pending_map, result, fn {_, parents}, acc ->
          Enum.reduce(parents, acc, fn parent, inner_acc ->
            Map.put(inner_acc, parent, other)
          end)
        end)
    end
  end
end
