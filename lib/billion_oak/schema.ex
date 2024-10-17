defmodule BillionOak.Schema do
  defmacro __using__(opts) do
    id_prefix = Keyword.fetch!(opts, :id_prefix)

    quote do
      use Ecto.Schema
      import Ecto.Changeset

      @type t :: %__MODULE__{}

      @primary_key {:id, :string, autogenerate: false}
      @foreign_key_type :string
      @timestamps_opts [type: :utc_datetime]

      def id_prefix, do: unquote(id_prefix)

      def prefix_id(id), do: "#{unquote(id_prefix)}_" <> id

      def bare_id("#{unquote(id_prefix)}_" <> id), do: id
      def bare_id(other), do: other

      def transform_id(%{id: id} = schema, :prefixed) when is_binary(id), do: %{schema | id: prefix_id(id)}
      def transform_id(%{id: id} = schema, :bare) when is_binary(id), do: %{schema | id: bare_id(id)}
      def transform_id(schema, _), do: schema

      def castable_fields do
        __struct__()
        |> Map.from_struct()
        |> Map.drop(__schema__(:associations))
        |> Map.drop([
          :__meta__,
          :id,
          :inserted_at,
          :updated_at
        ])
        |> Map.keys()
      end

      def changeset(%{id: nil} = struct), do: change(struct, id: XCUID.generate())
      def changeset(struct), do: change(struct)

      def entries(changesets) when is_list(changesets) do
        now = DateTime.utc_now(:second)

        Enum.map(changesets, fn changeset ->
          changeset.data
          |> Map.take(castable_fields())
          |> Map.merge(changeset.changes)
          |> Map.merge(%{
            inserted_at: now,
            updated_at: now
          })
        end)
      end
    end
  end
end
