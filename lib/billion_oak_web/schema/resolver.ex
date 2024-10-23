defmodule BillionOakWeb.Resolver do
  use OK.Pipe
  alias BillionOak.{Request, Response}

  def sign_up(_parent, args, %{context: context}) do
    context
    |> build_request(args, :mutation)
    |> BillionOak.sign_up()
    ~> unwrap_response(:mutation)
  end

  def get_company_account_excerpt(_parent, args, %{context: context}) do
    context
    |> build_request(args, :query)
    |> BillionOak.get_company_account_excerpt()
    ~> unwrap_response(:query)
  end

  def create_invitation_code(_parent, args, %{context: context}) do
    context
    |> build_request(args, :mutation)
    |> BillionOak.create_invitation_code()
    ~> unwrap_response(:mutation)
  end

  def build_request(context, args, :query) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id],
      identifier: args
    }
  end

  def build_request(context, args, :mutation) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id],
      data: args
    }
  end

  def unwrap_response(%Response{data: data}, :query), do: data
  def unwrap_response(%Response{data: data}, :mutation), do: data
end
