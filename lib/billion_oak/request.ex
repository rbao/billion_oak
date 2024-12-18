defmodule BillionOak.Request do
  @behaviour Access
  @moduledoc """
  Use this module to wrap and modify request data to pass in to API functions.

  ## Fields

  - `requester_id` - The user's ID that is making this request.
  - `client_id` - The app's ID that is making the request on behalf of the user.

  All other fields are self explanatory. Not all fields are used for all API functions,
  for example if you provide a pagination for a function that create a single resource
  it will have no effect.

  Fields in the form of `_****_` are not meant to be directly used, you should never
  set them to any user provided data. These fields are used by the internal system.
  """

  use TypedStruct

  typedstruct do
    field :requester_id, String.t()
    field :client_id, String.t()
    field :organization_id, String.t()
    field :data, map(), default: %{}
    field :identifier, map(), default: %{}
    field :filter, list() | map(), default: []
    field :search, String.t()
    field :pagination, map() | nil, default: %{size: 10, number: 1}
    field :sort, list(), default: []
    field :include, [String.t()]

    field :_requester_, map()
    field :_client_, map()
    field :_role_, String.t()
    field :_identifiable_keys_, atom() | [String.t()], default: :all
    field :_include_filters_, map(), default: %{}
    field :_filterable_keys_, atom() | [String.t()] | [atom()], default: :all
    field :_searchable_keys_, [String.t()], default: []
    field :_sortable_keys_, [String.t()], default: :all
  end

  def put(req, root_key, key, value) do
    root_value =
      req
      |> Map.get(root_key)
      |> Map.put(key, value)

    Map.put(req, root_key, root_value)
  end

  def put(req, key, value), do: Map.put(req, key, value)

  # Only merges key with non nil values
  def merge(req, args, permitted_keys) do
    args
    |> Map.take(permitted_keys)
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Enum.into(%{})
    |> then(&Map.merge(req, &1))
  end

  def delete(req, root_key, key) do
    root_value =
      req
      |> Map.get(root_key)
      |> Map.delete(key)

    Map.put(req, root_key, root_value)
  end

  def delete(req, key), do: Map.delete(req, key)

  def take(req, root_key, keys) do
    root_value = Map.get(req, root_key)
    Map.take(root_value, keys)
  end

  def get(req, key) when is_atom(key) or is_binary(key) do
    Map.get(req, key)
  end

  def get(req, key) do
    req
    |> Map.from_struct()
    |> get_in(key)
  end

  def add_filter(%{filter: filter} = req, key, value) do
    filter = filter ++ [%{key => value}]
    put(req, :filter, filter)
  end

  # Fetch a value from the struct
  def fetch(struct, key) do
    if Map.has_key?(struct, key) do
      {:ok, Map.get(struct, key)}
    else
      :error
    end
  end

  # Get and update a value in the struct
  def get_and_update(struct, key, fun) do
    if Map.has_key?(struct, key) do
      value = Map.get(struct, key)

      case fun.(value) do
        {get_value, new_value} ->
          {get_value, %{struct | key => new_value}}

        :pop ->
          {value, Map.delete(struct, key)}
      end
    else
      :error
    end
  end

  # Pop a value from the struct
  def pop(struct, key) do
    if Map.has_key?(struct, key) do
      value = Map.get(struct, key)
      {value, Map.delete(struct, key)}
    else
      :error
    end
  end
end
