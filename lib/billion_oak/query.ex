defmodule BillionOak.Query do
  import Ecto.Query
  import BillionOak.Normalization
  alias Ecto.{Query, Queryable}
  alias BillionOak.Repo
  alias BillionOak.Query.Filter

  @spec filter(Query.t(), map, [String.t()]) :: Query.t()
  def filter(query, filter, filterable_keys) when is_map(filter) do
    if map_size(filter) > 0 do
      filter(query, [filter], filterable_keys)
    else
      query
    end
  end

  @spec filter(Query.t(), [map], [String.t()]) :: Query.t()
  def filter(query, filter, filterable_keys) do
    filter = stringify_keys(filter)
    filterable_keys = stringify_list(filterable_keys)

    if has_assoc_field(filterable_keys) do
      Filter.with_assoc(query, filter, filterable_keys)
    else
      Filter.attr_only(query, filter, filterable_keys)
    end
  end

  defp has_assoc_field(:all), do: false

  defp has_assoc_field(fields) do
    Enum.any?(fields, fn field ->
      Filter.is_assoc(field)
    end)
  end

  @spec sort(Query.t(), [map], [String.t()]) :: Query.t()
  def sort(query, [], _), do: query
  def sort(query, _, []), do: query

  def sort(query, sort, sortable_keys) do
    orderings =
      Enum.reduce(sort, [], fn sorter, acc ->
        {field, ordering} = Enum.at(sorter, 0)

        if (field in sortable_keys || sortable_keys == :all) && ordering in ["asc", "desc"] do
          acc ++ [{String.to_existing_atom(ordering), String.to_existing_atom(field)}]
        else
          acc
        end
      end)

    order_by(query, ^orderings)
  end

  def paginate(query, nil), do: query

  @spec paginate(Query.t(), map) :: Query.t()
  def paginate(query, %{number: number} = pagination) when is_integer(number) do
    size = pagination[:size] || 25
    offset = size * (number - 1)

    query
    |> limit(^size)
    |> offset(^offset)
  end

  def paginate(query, pagination) do
    before_sid = sid(query, pagination[:before_id])
    after_sid = sid(query, pagination[:after_id])
    size = pagination[:size] || 25
    query = limit(query, ^size)

    if before_sid || after_sid do
      query
      |> exclude(:order_by)
      |> order_by(desc: :sid)
      |> apply_cursor(before_sid, after_sid)
    else
      query
    end
  end

  defp apply_cursor(query, before_sid, _) when is_integer(before_sid) do
    where(query, [q], q.sid > ^before_sid)
  end

  defp apply_cursor(query, _, after_sid) when is_integer(after_sid) do
    where(query, [q], q.sid < ^after_sid)
  end

  defp sid(_, nil), do: nil

  defp sid(query, id) do
    {_, queryable} = query.from
    data = Repo.get(queryable, id)

    if data, do: data.sid, else: nil
  end

  @spec for_organization(Query.t(), String.t() | nil) :: Query.t()
  def for_organization(query, nil), do: query

  def for_organization(query, organization_id) do
    from(q in query, where: q.organization_id == ^organization_id)
  end

  def to_query(queryable) do
    Queryable.to_query(queryable)
  end
end
