defmodule BillionOakWeb.Authentication do
  alias BillionOakWeb.JWT

  @errors [
    unsupported_grant_type: {:error, %{error: :unsupported_grant_type, error_description: "\"grant_type\" must be one of \"password\" or \"refresh_token\""}},
    invalid_password: {:error, %{error: :invalid_grant, error_description: "Username and password does not match."}},
    invalid_refresh_token: {:error, %{error: :invalid_grant, error_description: "Refresh token is invalid."}},
    invalid_request: {:error, %{error: :invalid_request, error_description: "Your request is missing required parameters or is otherwise malformed."}},
    invalid_client: {:error, %{error: :invalid_client, error_description: "Client is invalid"}}
  ]

  def create_access_token(%{"grant_type" => grant_type}) when grant_type not in ["refresh_token", "password"] do
    @errors[:unsupported_grant_type]
  end

  def create_access_token(%{"grant_type" => "refresh_token", "client_id" => client_id, "refresh_token" => refresh_token}) do
    # TODO
  end

  def create_access_token(%{"grant_type" => "password"}) do
    # TODO
  end
end
