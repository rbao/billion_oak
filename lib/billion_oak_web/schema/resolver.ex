defmodule BillionOakWeb.Resolver do
  use OK.Pipe
  alias BillionOak.{Request, Response}

  def get_company_account_excerpt(_parent, args, %{context: context}) do
    context
    |> build_request(args, :get)
    |> BillionOak.get_company_account_excerpt()
    ~> unwrap_response(:get)
  end

  def create_invitation_code(_parent, args, %{context: context}) do
    context
    |> build_request(args, :create)
    |> BillionOak.create_invitation_code()
    ~> unwrap_response(:create)
  end

  def build_request(context, args, :get) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id],
      identifier: args
    }
  end

  def build_request(context, args, :create) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id],
      data: args,
    }
  end

  def unwrap_response(%Response{data: data}, :get), do: data
  def unwrap_response(%Response{data: data}, :create), do: data
end
