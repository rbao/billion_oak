defmodule BillionOak do
  use OK.Pipe
  import BillionOak.Policy

  alias BillionOak.{
    External,
    Identity,
    Ingestion,
    Filestore,
    Content,
    Request,
    Response,
    Validation
  }

  alias BillionOak.Identity.{Client, User}

  @moduledoc """
  BillionOak keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defmacro cfun do
    quote do
      {name, _} = __ENV__.function
      name
    end
  end

  def create_company(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> External.create_company()
    |> to_create_response()
  end

  def create_organization(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Identity.create_organization()
    |> to_create_response()
  end

  def create_client(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Identity.create_client()
    |> to_create_response()
  end

  def verify_client(%Request{} = req) do
    Identity.verify_client(req)
    |> to_get_response()
  end

  def get_or_create_user(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Identity.get_or_create_user()
    |> to_create_response()
  end

  def get_organization(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Identity.get_organization()
    |> to_get_response()
  end

  def create_invitation_code(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Identity.create_invitation_code()
    |> to_create_response()
  end

  def sign_up(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Identity.sign_up()
    |> to_create_response()
  end

  def update_current_user(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Identity.update_user()
    |> to_update_response()
  end

  def get_company_account_excerpt(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~> Request.take(:identifier, [:organization_id, :rid])
    ~>> External.get_company_account_excerpt()
    |> to_get_response()
  end

  def get_user(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Identity.get_user()
    |> to_get_response()
  end

  def get_sharer(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Identity.get_sharer()
    |> to_get_response()
  end

  def list_company_accounts(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> External.list_company_accounts()
    |> to_list_response()
  end

  def ingest_external_data(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Ingestion.run()
    |> to_bulk_create_response()
  end

  def reserve_file_location(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Filestore.reserve_location()
    |> to_create_response()
  end

  def register_file(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Filestore.register_file()
    |> to_create_response()
  end

  def create_audio(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Content.create_audio()
    |> to_create_response()
  end

  def list_audios(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> do_list_audio()
  end

  defp do_list_audio(req) do
    audios = Content.list_audios(req)
    total_count = Content.count_audios(req)

    resp = %Response{
      meta: %{
        total_count: total_count,
        pagination: req.pagination
      },
      data: audios
    }

    {:ok, resp}
  end

  def update_audio(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Content.update_audio()
    |> to_update_response()
  end

  def update_audios(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Content.update_audios()
    |> to_bulk_update_response()
  end

  def delete_audios(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Content.delete_audios()
    |> to_delete_response()
  end

  def get_audio(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Content.get_audio()
    |> to_get_response()
  end

  def list_files(%Request{} = req) do
    req
    |> expand()
    |> scope_authorize(cfun())
    ~>> Filestore.list_files()
    |> to_list_response()
  end

  defp expand(%Request{} = req) do
    req
    |> Request.put(:client_id, Client.bare_id(req.client_id))
    |> put_client()
    |> put_organization_id()
    |> Request.put(:requester_id, User.bare_id(req.requester_id))
    |> put_requester()
    |> put_role()
  end

  defp put_client(%Request{client_id: nil} = req), do: req

  defp put_client(%Request{client_id: client_id} = req) do
    case Identity.get_client(id: client_id) do
      {:ok, client} -> %{req | _client_: client}
      {:error, :not_found} -> req
    end
  end

  defp put_organization_id(%Request{_client_: nil} = req), do: req

  defp put_organization_id(%Request{_client_: client} = req) do
    %{req | organization_id: client.organization_id}
  end

  defp put_requester(%Request{organization_id: nil} = req), do: req
  defp put_requester(%Request{requester_id: nil} = req), do: req
  defp put_requester(%Request{requester_id: "anon_" <> _} = req), do: req

  defp put_requester(%Request{requester_id: requester_id, organization_id: organization_id} = req) do
    case Identity.get_user(id: requester_id, organization_id: organization_id) do
      {:ok, requester} -> %{req | _requester_: requester}
      {:error, :not_found} -> req
    end
  end

  defp put_role(%Request{_requester_: nil, _role_: nil} = req), do: %{req | _role_: :anonymous}

  defp put_role(%Request{_requester_: requester, _role_: nil} = req),
    do: %{req | _role_: requester.role}

  defp put_role(%Request{} = req), do: req

  defp to_bulk_update_response({:ok, data}), do: {:ok, %Response{data: data}}

  defp to_bulk_update_response({:error, [%Ecto.Changeset{} | _] = changesets}) do
    {:error, {:validation_error, %Response{errors: Validation.errors(changesets)}}}
  end

  defp to_bulk_update_response(other), do: other

  defp to_bulk_create_response({:ok, data}), do: {:ok, %Response{data: data}}
  defp to_bulk_create_response(other), do: other

  defp to_create_response({:ok, data}), do: {:ok, %Response{data: data}}

  defp to_create_response({:error, %Ecto.Changeset{} = changeset}) do
    {:error, {:validation_error, %Response{errors: Validation.errors(changeset)}}}
  end

  defp to_create_response(other), do: other

  defp to_list_response({:ok, data}), do: {:ok, %Response{data: data}}
  defp to_list_response(other), do: other

  defp to_update_response({:ok, data}), do: {:ok, %Response{data: data}}

  defp to_update_response({:error, %Ecto.Changeset{} = changeset}) do
    {:error, {:validation_error, %Response{errors: Validation.errors(changeset)}}}
  end

  defp to_update_response(other), do: other

  defp to_get_response({:ok, data}), do: {:ok, %Response{data: data}}
  defp to_get_response(other), do: other

  defp to_delete_response({:ok, {count, data}}) do
    {:ok, %Response{meta: %{count: count}, data: data}}
  end

  defp to_delete_response(other), do: other
end
