defmodule BillionOakWeb.Schema.DataSource do
  def data do
    Dataloader.KV.new(&query/2)
  end

  def query({:company_account, _, context}, parents) do
    IO.inspect(context)
    {result, company_account_ids} = Enum.reduce(parents, {%{}, []}, fn parent, {loaded_accounts, unloaded_ids} ->
      case parent.company_account do
        %{id: id} = company_account ->
          {Map.put(loaded_accounts, id, company_account), unloaded_ids}
        _ ->
          {loaded_accounts, [parent.company_account_id | unloaded_ids]}
      end
    end)

    result
  end
end
