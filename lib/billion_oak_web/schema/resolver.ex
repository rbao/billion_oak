defmodule BillionOakWeb.Schema.Resolver do
  use OK.Pipe
  import Absinthe.Resolution.Helpers
  import BillionOakWeb.Schema.Helper
  alias BillionOakWeb.Schema.DataSource

  def sign_up(_parent, args, %{context: context}) do
    context
    |> build_request(args, :mutation)
    |> BillionOak.sign_up()
    |> build_response(:mutation)
  end

  def get_company_account_excerpt(_parent, args, %{context: context}) do
    context
    |> build_request(args, :query)
    |> BillionOak.get_company_account_excerpt()
    |> build_response(:query)
  end

  def create_invitation_code(_parent, args, %{context: context}) do
    context
    |> build_request(args, :mutation)
    |> BillionOak.create_invitation_code()
    |> build_response(:mutation)
  end

  def get_current_user(_parent, _args, %{context: context}) do
    context
    |> build_request(%{id: context[:requester_id]}, :query)
    |> BillionOak.get_user()
    |> build_response(:query)
  end

  def load_company_accounts(parent, _args, %{context: %{loader: loader} = context}) do
    context = Map.drop(context, [:loader])

    loader
    |> Dataloader.load(DataSource, {:company_account, %{}, context}, parent)
    |> on_load(fn loader ->
      {:ok, Dataloader.get(loader, DataSource, {:company_account, %{}, context}, parent)}
    end)
  end

  def reserve_file_location(_parent, args, %{context: context}) do
    context
    |> build_request(args, :mutation)
    |> BillionOak.reserve_file_location()
    |> build_response(:mutation)
  end

  def register_file(_parent, args, %{context: context}) do
    context
    |> build_request(args, :mutation)
    |> BillionOak.register_file()
    |> build_response(:mutation)
  end

  def create_audio(_parent, args, %{context: context}) do
    context
    |> build_request(args, :mutation)
    |> BillionOak.create_audio()
    |> build_response(:mutation)
  end
end
