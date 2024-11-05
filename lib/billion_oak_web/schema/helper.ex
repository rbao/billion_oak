defmodule BillionOakWeb.Schema.Helper do
  alias BillionOak.{Request, Response}

  def build_request(context, args, :list) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id]
    }
    |> Request.merge(args, [:filter, :pagination])
    |> put_sort(args)
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
      data: args
    }
  end

  def build_request(context, args, :update, filter_keys \\ [:id]) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id],
      filter: Map.take(args, filter_keys),
      data: Map.drop(args, filter_keys)
    }
  end

  def build_delete_request(context, args, filter_keys \\ [:id]) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id],
      filter: Map.take(args, filter_keys)
    }
  end

  defp put_sort(req, %{sort: sort}) when is_list(sort) do
    sort =
      Enum.reduce(sort, [], fn %{field: field, ordering: ordering}, acc ->
        acc ++ [%{Macro.underscore(field) => ordering}]
      end)

    Request.put(req, :sort, sort)
  end

  defp put_sort(req, _), do: req

  def to_output({:ok, %Response{} = resp}, :get) do
    {:ok, Map.take(resp, [:data, :meta])}
  end

  def to_output(other, :get), do: other

  def to_output({:ok, %Response{} = resp}, :list) do
    {:ok, Map.take(resp, [:data, :meta])}
  end

  def to_output(other, :list), do: other

  def to_output({:ok, %Response{data: data}}, :create), do: {:ok, data}

  def to_output(
        {:error, {:validation_error, %Response{errors: validation_errors}}},
        :create
      ) do
    errors =
      Enum.reduce(validation_errors, [], fn {key, error_code, message, details}, acc ->
        acc ++ [%{key: key, error_code: error_code, message: message, details: details}]
      end)

    {:error, errors}
  end

  def to_output(other, :create), do: other

  def to_output({:ok, %Response{data: data}}, :update), do: {:ok, data}

  def to_output({:error, {:validation_error, %Response{errors: validation_errors}}}, :update) do
    errors =
      Enum.reduce(validation_errors, [], fn {id, errors}, acc ->
        Enum.reduce(errors, acc, fn {key, error_code, message, details}, acc ->
          acc ++ [%{id: id, key: key, error_code: error_code, message: message, details: details}]
        end)
      end)

    {:error, errors}
  end

  def to_output(other, :update), do: other

  def to_output({:ok, %Response{} = resp}, :list) do
    {:ok, Map.take(resp, [:data, :meta])}
  end

  def to_output(other, :delete), do: other
end
