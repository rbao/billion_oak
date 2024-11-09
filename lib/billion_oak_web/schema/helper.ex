defmodule BillionOakWeb.Schema.Helper do
  alias BillionOak.{Request, Response}

  def build_get_request(context, args) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id],
      identifier: args
    }
  end

  def build_create_request(context, args) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id],
      data: args
    }
  end

  def build_list_request(context, args) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id]
    }
    |> Request.merge(args, [:filter, :pagination, :search])
    |> put_sort(args)
  end

  def build_bulk_update_request(context, args, filter_keys \\ [:id]) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id],
      filter: Map.take(args, filter_keys),
      data: Map.drop(args, filter_keys)
    }
  end

  def build_update_request(context, args, identifier_keys \\ [:id]) do
    %Request{
      client_id: context[:client_id],
      requester_id: context[:requester_id],
      identifier: Map.take(args, identifier_keys),
      data: Map.drop(args, identifier_keys)
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

  def to_list_output({:ok, %Response{} = resp}), do: {:ok, Map.take(resp, [:data, :meta])}
  def to_list_output(other), do: other

  def to_create_output({:ok, %Response{} = resp}), do: {:ok, Map.take(resp, [:data, :meta])}

  def to_create_output({:error, {:validation_error, %Response{errors: validation_errors}}}) do
    errors =
      Enum.reduce(validation_errors, [], fn {key, error_code, message, details}, acc ->
        acc ++ [%{key: key, error_code: error_code, message: message, details: details}]
      end)

    {:error, errors}
  end

  def to_create_output(other), do: other

  def to_update_output({:ok, %Response{} = resp}), do: {:ok, Map.take(resp, [:data, :meta])}

  def to_update_output({:error, {:validation_error, %Response{errors: validation_errors}}}) do
    errors =
      Enum.reduce(validation_errors, [], fn {key, error_code, message, details}, acc ->
        acc ++ [%{key: key, error_code: error_code, message: message, details: details}]
      end)

    {:error, errors}
  end

  def to_update_output(other), do: other

  def to_get_output({:ok, %Response{} = resp}), do: {:ok, Map.take(resp, [:data, :meta])}
  def to_get_output(other), do: other

  def to_bulk_update_output({:ok, %Response{} = resp}), do: {:ok, Map.take(resp, [:data, :meta])}

  def to_bulk_update_output({:error, {:validation_error, %Response{errors: validation_errors}}}) do
    errors =
      Enum.reduce(validation_errors, [], fn {id, errors}, acc ->
        Enum.reduce(errors, acc, fn {key, error_code, message, details}, acc ->
          acc ++ [%{id: id, key: key, error_code: error_code, message: message, details: details}]
        end)
      end)

    {:error, errors}
  end

  def to_bulk_update_output(other), do: other

  def to_delete_output(other), do: other
end
