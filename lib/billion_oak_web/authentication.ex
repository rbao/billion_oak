defmodule BillionOakWeb.Authentication do
  use OK.Pipe
  alias BillionOak.Identity
  alias BillionOakWeb.JWT

  @error_detail [
    unsupported_grant_type: %{
      error: :unsupported_grant_type,
      error_description: "grant_type must be client_credentials, refresh_token or password"
    },
    invalid_password: %{
      error: :invalid_grant,
      error_description: "Username and password does not match."
    },
    invalid_refresh_token: %{
      error: :invalid_grant,
      error_description: "Refresh token is invalid."
    },
    invalid_request: %{
      error: :invalid_request,
      error_description: "Your request is missing required parameters or is otherwise malformed."
    },
    invalid_client: %{
      error: :invalid_client,
      error_description: "Client is invalid"
    }
  ]

  def create_access_token(%{grant_type: grant_type})
      when grant_type not in ["client_credentials", "refresh_token", "password"] do
    {:error, @error_detail[:unsupported_grant_type]}
  end

  def create_access_token(%{
        grant_type: "client_credentials",
        client_id: client_id,
        client_secret: client_secret
      }) do
    case Identity.verify_client(client_id, client_secret) do
      {:ok, client} ->
        claims = %{"aud" => client.id, "sub" => "anon" <> XCUID.generate()}
        {:ok, JWT.generate_and_sign!(claims)}

      {:error, _} ->
        {:error, @error_detail[:invalid_client]}
    end
  end

  def create_access_token(%{"grant_type" => "password"}) do
    # TODO
  end
end
