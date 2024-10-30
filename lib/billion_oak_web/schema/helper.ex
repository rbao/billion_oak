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

  def build_response({:ok, %Response{data: data}}, :query), do: {:ok, data}
  def build_response(other, :query), do: other

  def build_response({:ok, %Response{data: data}}, :mutation), do: {:ok, data}

  def build_response(
        {:error, {:validation_error, %Response{errors: validation_errors}}},
        :mutation
      ) do
    errors =
      Enum.reduce(validation_errors, [], fn {key, error_code, message, details}, acc ->
        acc ++ [%{key: key, error_code: error_code, message: message, details: details}]
      end)

    {:error, errors}
  end

  def build_response(other, :mutation), do: other
end
