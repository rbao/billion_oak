defmodule BillionOak.Validation.Error do
  @type t :: {atom, atom, String.t(), Keyword.t()}
  @type changeset :: %{
          validations: [{atom, any}],
          errors: [{atom, {String.t(), Keyword.t()}}]
        }

  @doc """
  Return a MapSet of all the keys with the given error code.
  """
  @spec keys_with_code([t()], atom) :: MapSet.t(atom)
  def keys_with_code(errors, code) do
    Enum.reduce(errors, MapSet.new(), fn
      {key, ^code, _, _}, acc -> MapSet.put(acc, key)
      _, acc -> acc
    end)
  end

  @doc """
  Return the first error code of the given key in the given list of errors.
  If there is no error for the given key `nil` is returned.
  """
  @spec code_for_key([t()], atom) :: atom | nil
  def code_for_key(errors, key) do
    error =
      Enum.find(errors, fn
        {^key, _, _, _} -> true
        _ -> false
      end)

    if error do
      {_, code, _, _} = error
      code
    else
      nil
    end
  end

  @doc """
  Return a normalized error list from the given changeset.

  The main difference between the error list returned and `changeset.errors`
  is that the error message will be changed to a reasonable error code and
  the original validation options will be returned as part of the list as well.
  """
  @spec from_changeset(changeset()) :: [t]
  def from_changeset(%{validations: settings, errors: errors}) do
    Enum.reduce(errors, [], fn {key, detail}, acc ->
      acc ++ [changeset_error(key, detail, settings)]
    end)
  end

  @doc """
  Similar to `from_changeset/1` except it takes in a list of `{index, changeset}`
  and return a list of `{index, [t]}`.
  """
  @spec from_changesets([{integer(), changeset()}]) :: [{integer(), [t]}]
  def from_changesets(changesets) do
    Enum.map(changesets, fn {index, changeset} ->
      {index, from_changeset(changeset)}
    end)
  end

  defp changeset_error(key, {msg, opts}, settings) do
    cond do
      Keyword.has_key?(opts, :validation) ->
        changeset_error(key, :validation, opts[:validation], msg, settings)

      Keyword.has_key?(opts, :constraint) ->
        changeset_error(key, :constraint, opts[:constraint], msg, settings)

      true ->
        {key, :unkown_error, []}
    end
  end

  defp changeset_error(key, :validation, :required, msg, _) do
    {key, :required, msg, []}
  end

  defp changeset_error(key, :validation, :length, msg, settings) do
    key_settings = Keyword.get_values(settings, key)

    length_settings =
      Enum.find(key_settings, fn
        {:length, _} -> true
        _ -> false
      end)

    {_, opts} = length_settings
    {key, :invalid_length, msg, opts}
  end

  defp changeset_error(key, :validation, :must_exist, msg, _) do
    {key, :not_found, msg, []}
  end

  defp changeset_error(key, :validation, :must_have_content, msg, _) do
    {key, :no_content, msg, []}
  end

  defp changeset_error(key, :validation, :must_match, msg, _) do
    {key, :mismatch, msg, []}
  end

  defp changeset_error(key, :validation, code, msg, _) do
    {key, code, msg, []}
  end

  defp changeset_error(key, :constraint, :unique, msg, _) do
    {key, :taken, msg, []}
  end
end
