defmodule BillionOak.Normalization do
  def atomize_keys(m, permitted \\ nil) do
    permitted_atom = permitted || Map.keys(m)
    permitted_string = stringify_list(permitted_atom)

    Enum.reduce(m, %{}, fn {k, v}, acc ->
      cond do
        is_binary(k) && Enum.member?(permitted_string, k) ->
          Map.put(acc, String.to_existing_atom(k), v)

        is_atom(k) && Enum.member?(permitted_atom, k) ->
          Map.put(acc, k, v)

        true ->
          acc
      end
    end)
  end

  def stringify_keys(list) when is_list(list), do: Enum.map(list, &do_stringify_value/1)
  def stringify_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} -> {do_stringify_key(k), do_stringify_value(v)} end)
    |> Enum.into(%{})
  end

  defp do_stringify_key(key) when is_atom(key), do: Atom.to_string(key)
  defp do_stringify_key(key) when is_binary(key), do: key

  defp do_stringify_value(value) when is_map(value), do: stringify_keys(value)
  defp do_stringify_value(value) when is_list(value), do: Enum.map(value, &do_stringify_value/1)
  defp do_stringify_value(value), do: value

  def stringify_list(l) when is_list(l) do
    Enum.reduce(l, [], fn item, acc ->
      if is_atom(item) do
        acc ++ [Atom.to_string(item)]
      else
        acc ++ [item]
      end
    end)
  end
  def stringify_list(other), do: other
end
