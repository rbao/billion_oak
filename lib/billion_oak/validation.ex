defmodule BillionOak.Validation do
  def invalid_changesets(changesets) do
    changesets
    |> Enum.with_index()
    |> Enum.reduce([], fn {changeset, index}, acc ->
      if changeset.valid? do
        acc
      else
        acc ++ [{index, changeset}]
      end
    end)
  end
end
