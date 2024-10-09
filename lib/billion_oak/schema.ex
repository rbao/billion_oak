defmodule BillionOak.Schema do
  defmacro __using__(opts) do
    id_prefix = Keyword.fetch!(opts, :id_prefix)

    quote do
      use Ecto.Schema
      import Ecto.Changeset

      @type t :: %__MODULE__{}

      @primary_key {:id, :string, autogenerate: false}
      @foreign_key_type :string
      @timestamps_opts [type: :utc_datetime_usec]

      def generate_id, do: "#{unquote(id_prefix)}_" <> XCUID.generate()
      def id_prefix, do: unquote(id_prefix)
      def prefix_id(id), do: "#{unquote(id_prefix)}_" <> id

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

      def changeset(%{id: nil} = struct), do: change(struct, id: generate_id())
      def changeset(struct), do: change(struct)
    end
  end
end
