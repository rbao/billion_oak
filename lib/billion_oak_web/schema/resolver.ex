defmodule BillionOakWeb.Resolver do
  use OK.Pipe
  alias BillionOak.{Request, Response}

  def list_companies(_parent, _args, _resolution) do
    {:ok, BillionOak.External.list_companies()}
  end

  def get_company_account_excerpt(_parent, args, %{context: context}) do
    context
    |> build_request(args, :get)
    |> BillionOak.get_company_account_excerpt()
    ~> unwrap_response(:get)
  end

  def build_request(context, args, :get) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id],
      identifier: Map.take(args, [:rid])
    }
  end

  def unwrap_response(%Response{data: data}, :get), do: data
end
