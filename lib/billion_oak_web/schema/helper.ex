defmodule BillionOakWeb.Schema.Helper do
  alias BillionOak.{Request, Response}

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
