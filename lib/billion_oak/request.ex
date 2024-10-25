defmodule BillionOak.Request do
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
    field :data, map(), default: %{}
    field :identifier, map(), default: %{}
    field :filter, list(), default: []
    field :search, String.t()
    field :pagination, map() | nil, default: %{size: 20, number: 1}
    field :sort, list(), default: []
    field :include, [String.t()]

    field :_organization_id_, String.t()
    field :_requester_, map()
    field :_client_, map()
    field :_role_, String.t()
    field :_identifiable_keys_, atom | [String.t()], default: :all
    field :_include_filters_, map(), default: %{}
    field :_filterable_keys_, atom | [String.t()], default: :all
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
end
