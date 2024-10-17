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

  def stringify_list(l) do
    Enum.reduce(l, [], fn item, acc ->
      if is_atom(item) do
        acc ++ [Atom.to_string(item)]
      else
        acc ++ [item]
      end
    end)
  end
end
