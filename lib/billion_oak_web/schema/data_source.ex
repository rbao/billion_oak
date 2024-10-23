defmodule BillionOakWeb.Schema.DataSource do
  def data do
    Dataloader.KV.new(&query/2)
  end

  def query({:company_account, _args}, _parents) do
    %{}
  end
end
