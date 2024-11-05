defmodule BillionOak.Validation do
  alias BillionOak.Validation.Error

  def invalid_changesets(changesets, :index) do
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

  def invalid_changesets(changesets) do
    changesets
    |> Enum.reduce([], fn changeset, acc ->
      if changeset.valid? do
        acc
      else
        acc ++ [changeset]
      end
    end)
  end

  def errors(changesets) when is_list(changesets) do
    Error.from_changesets(changesets)
  end

  def errors(changeset) do
    Error.from_changeset(changeset)
  end
end
