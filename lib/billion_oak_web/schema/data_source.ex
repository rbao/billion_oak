defmodule BillionOakWeb.Schema.DataSource do
  use OK.Pipe
  import BillionOakWeb.Schema.Helper
  alias BillionOak.Request

  def data do
    Dataloader.KV.new(&query/2)
  end

  def query({:company_account, _, context}, parents) do
    {result, pending_map} = split(parents, :company_account, :company_account_id)

    context
    |> build_list_request(%{id: Map.keys(pending_map)})
    |> BillionOak.list_company_accounts()
    |> to_list_output()
    |> merge_result(pending_map, result)
  end

  def query({:file, %{id_field: id_field, file_field: file_field}, context}, parents) do
    {result, pending_map} = split(parents, file_field, id_field)

    context
    |> build_list_request(%{filter: %{id: Map.keys(pending_map)}})
    |> Request.put(:pagination, nil)
    |> BillionOak.list_files()
    |> to_list_output()
    |> treat_access_denied_as_empty()
    |> merge_result(pending_map, result)
  end

  defp split(parents, assoc_field, id_field) do
    Enum.reduce(parents, {%{}, %{}}, fn parent, {loaded, pending_map} ->
      case Map.get(parent, assoc_field) do
        %{id: _} = assoc ->
          {Map.put(loaded, parent, assoc), pending_map}

        _ ->
          {loaded, Map.update(pending_map, Map.get(parent, id_field), [parent], &[parent | &1])}
      end
    end)
  end

  defp merge_result({:ok, %{data: data}}, pending_map, result) do
    # Merge found result to the result
    found_result =
      Enum.reduce(data, result, fn item, acc ->
        Enum.reduce(Map.get(pending_map, Map.get(item, :id), []), acc, fn parent, inner_acc ->
          Map.put(inner_acc, parent, item)
        end)
      end)

    # Set any parent that did not found the child as nil
    Enum.reduce(pending_map, found_result, fn {_, parents}, acc ->
      Enum.reduce(parents, acc, fn parent, inner_acc ->
        if not Map.has_key?(inner_acc, parent) do
          Map.put(inner_acc, parent, nil)
        else
          inner_acc
        end
      end)
    end)
  end

  defp merge_result(other, pending_map, result) do
    Enum.reduce(pending_map, result, fn {_, parents}, acc ->
      Enum.reduce(parents, acc, fn parent, inner_acc ->
        Map.put(inner_acc, parent, other)
      end)
    end)
  end

  defp treat_access_denied_as_empty(result) do
    case result do
      {:error, :access_denied} -> {:ok, %{data: []}}
      other -> other
    end
  end
end
