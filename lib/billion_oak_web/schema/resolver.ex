defmodule BillionOakWeb.Schema.Resolver do
  use OK.Pipe
  import Absinthe.Resolution.Helpers
  import BillionOakWeb.Schema.Helper
  alias BillionOakWeb.Schema.DataSource

  def sign_up(_parent, args, %{context: context}) do
    context
    |> build_request(args, :create)
    |> BillionOak.sign_up()
    |> to_output(:create)
  end

  def get_company_account_excerpt(_parent, args, %{context: context}) do
    context
    |> build_request(args, :get)
    |> BillionOak.get_company_account_excerpt()
    |> to_output(:get)
  end

  def create_invitation_code(_parent, args, %{context: context}) do
    context
    |> build_request(args, :create)
    |> BillionOak.create_invitation_code()
    |> to_output(:create)
  end

  def get_current_user(_parent, _args, %{context: context}) do
    context
    |> build_request(%{id: context[:requester_id]}, :get)
    |> BillionOak.get_user()
    |> to_output(:get)
  end

  def reserve_file_location(_parent, args, %{context: context}) do
    context
    |> build_request(args, :create)
    |> BillionOak.reserve_file_location()
    |> to_output(:create)
  end

  def register_file(_parent, args, %{context: context}) do
    context
    |> build_request(args, :create)
    |> BillionOak.register_file()
    |> to_output(:create)
  end

  def create_audio(_parent, %{input: input}, %{context: context}) do
    context
    |> build_request(input, :create)
    |> BillionOak.create_audio()
    |> to_output(:create)
  end

  def list_audios(_parent, %{input: input}, %{context: context}) do
    context
    |> build_request(input, :list)
    |> BillionOak.list_audios()
    |> to_output(:list)
  end

  def update_audios(_parent, %{input: input}, %{context: context}) do
    context
    |> build_request(input, :update)
    |> BillionOak.update_audios()
    |> to_output(:update)
  end

  def delete_audios(_parent, %{input: input}, %{context: context}) do
    context
    |> build_delete_request(input)
    |> BillionOak.delete_audios()
    |> to_output(:delete)
  end

  def get_audio(_parent, %{input: input}, %{context: context}) do
    context
    |> build_request(input, :get)
    |> BillionOak.get_audio()
    |> to_output(:get)
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
    context = Map.drop(context, [:loader])

    loader
    |> Dataloader.load(DataSource, {:file, %{}, context}, parent)
    |> on_load(fn loader ->
      {:ok, Dataloader.get(loader, DataSource, {:file, %{}, context}, parent)}
    end)
  end
end
