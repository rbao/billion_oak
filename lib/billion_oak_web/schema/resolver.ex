defmodule BillionOakWeb.Schema.Resolver do
  use OK.Pipe
  import Absinthe.Resolution.Helpers
  import BillionOakWeb.Schema.Helper
  alias BillionOakWeb.Schema.DataSource
  alias BillionOak.Content.Audio
  alias BillionOak.Identity.User

  def get_current_user(_parent, _args, %{context: context}) do
    context
    |> build_get_request(%{id: context[:requester_id]})
    |> BillionOak.get_user()
    |> to_get_output()
  end

  def get_sharer(_parent, %{input: input}, %{context: context}) do
    context
    |> build_get_request(input)
    |> BillionOak.get_sharer()
    |> to_get_output()
  end

  def get_company_account_excerpt(_parent, args, %{context: context}) do
    context
    |> build_get_request(args)
    |> BillionOak.get_company_account_excerpt()
    |> to_get_output()
  end

  def sign_up(_parent, args, %{context: context}) do
    context
    |> build_create_request(args)
    |> BillionOak.sign_up()
    |> to_create_output()
  end

  def update_current_user(_parent, %{input: input}, %{context: context}) do
    context
    |> build_update_request(input)
    |> BillionOak.update_current_user()
    |> to_update_output()
  end

  def create_invitation_code(_parent, %{input: input}, %{context: context}) do
    context
    |> build_create_request(input)
    |> BillionOak.create_invitation_code()
    |> to_create_output()
  end

  def reserve_file_location(_parent, args, %{context: context}) do
    context
    |> build_create_request(args)
    |> BillionOak.reserve_file_location()
    |> to_create_output()
  end

  def register_file(_parent, args, %{context: context}) do
    context
    |> build_create_request(args)
    |> BillionOak.register_file()
    |> to_create_output()
  end

  def create_audio(_parent, %{input: input}, %{context: context}) do
    context
    |> build_create_request(input)
    |> BillionOak.create_audio()
    |> to_create_output()
  end

  def list_audios(_parent, %{input: input}, %{context: context}) do
    context
    |> build_list_request(input)
    |> BillionOak.list_audios()
    |> to_list_output()
  end

  def update_audios(_parent, %{input: input}, %{context: context}) do
    context
    |> build_bulk_update_request(input)
    |> BillionOak.update_audios()
    |> to_bulk_update_output()
  end

  def update_audio(_parent, %{input: input}, %{context: context}) do
    context
    |> build_update_request(input)
    |> BillionOak.update_audio()
    |> to_update_output()
  end

  def delete_audios(_parent, %{input: input}, %{context: context}) do
    context
    |> build_delete_request(input)
    |> BillionOak.delete_audios()
    |> to_delete_output()
  end

  def get_audio(_parent, %{input: input}, %{context: context}) do
    context
    |> build_get_request(input)
    |> BillionOak.get_audio()
    |> to_get_output()
  end

  def load_company_accounts(parent, _args, %{context: %{loader: loader} = context}) do
    context = Map.drop(context, [:loader])

    loader
    |> Dataloader.load(DataSource, {:company_account, %{}, context}, parent)
    |> on_load(fn loader ->
      {:ok, Dataloader.get(loader, DataSource, {:company_account, %{}, context}, parent)}
    end)
  end

  def load_files(parent, _args, %{context: %{loader: loader} = context}) do
    do_load_files(loader, context, parent)
  end

  defp do_load_files(loader, context, %Audio{} = audio) do
    args = %{id_field: :primary_file_id, file_field: :primary_file}
    do_load_files(loader, args, context, audio)
  end

  defp do_load_files(loader, context, %User{} = user) do
    args = %{id_field: :avatar_file_id, file_field: :avatar_file}
    do_load_files(loader, args, context, user)
  end

  defp do_load_files(loader, args, context, parent) do
    loader
    |> Dataloader.load(DataSource, {:file, args, context}, parent)
    |> on_load(fn loader ->
      {:ok, Dataloader.get(loader, DataSource, {:file, args, context}, parent)}
    end)
  end
end
