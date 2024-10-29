defmodule BillionOak.Filestore.FileLocation do
  use BillionOak.Schema, id_prefix: "filoc"
  alias BillionOak.Filestore.Client

  schema "file_locations" do
    field :name, :string
    field :content_type, :string, virtual: true
    field :form_url, :string, virtual: true
    field :form_fields, {:array, :map}, virtual: true

    timestamps()

    belongs_to :organization, Organization
    belongs_to :owner, User
  end

  def changeset(location, attrs) do
    location
    |> changeset()
    |> cast(attrs, castable_fields())
    |> validate_required([:name, :owner_id, :organization_id])
    |> put_form_data()
  end

  defp put_form_data(%{valid?: false} = cs), do: cs

  defp put_form_data(cs) do
    id = get_field(cs, :id)
    name = get_field(cs, :name)

    content_type = get_field(cs, :content_type)
    custom_conditions = if content_type, do: [%{"Content-Type" => content_type}], else: []

    form =
      id
      |> key(name)
      |> Client.presigned_post(custom_conditions)

    form_fields =
      Enum.reduce(form.fields, [], fn {k, v}, acc ->
        [%{name: k, value: v} | acc]
      end)

    cs
    |> change(form_fields: form_fields)
    |> change(form_url: form.url)
  end

  defp key(id, name) do
    "#{id}/#{name}"
  end
end
