defmodule BillionOakWeb.Schema.Helper do
  alias BillionOak.{Request, Response}

  def build_request(context, args, :list) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id]
    }
    |> Request.merge(args, [:filter, :pagination])
  end

  def build_request(context, args, :get) do
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

  def build_response({:ok, %Response{data: data}}, :get), do: {:ok, data}
  def build_response(other, :get), do: other

  def build_response({:ok, %Response{data: data}}, :list), do: {:ok, data}
  def build_response(other, :list), do: other

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
