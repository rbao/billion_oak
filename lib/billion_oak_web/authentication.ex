defmodule BillionOakWeb.Authentication do
  use OK.Pipe
  alias BillionOak.Request
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
    invalid_code: %{
      error: :invalid_grant,
      error_description: "Code is invalid."
    },
    user_blocked: %{
      error: :invalid_grant,
      error_description: "User is blocked by WeChat."
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
      when grant_type not in ["client_credentials", "refresh_token", "code"] do
    {:error, @error_detail[:unsupported_grant_type]}
  end

  def create_access_token(%{
        grant_type: "code",
        code: code,
        client_id: client_id,
        client_secret: client_secret
      }) do
    result =
      %Request{identifier: %{id: client_id}, data: %{secret: client_secret}}
      |> BillionOak.verify_client()
      ~> Map.get(:data)
      ~>> get_openid(code)
      ~> then(&%Request{client_id: client_id, identifier: %{wx_app_openid: &1}})
      ~>> BillionOak.get_or_create_user()

    case result do
      {:ok, %{data: user}} ->
        claims = %{"aud" => client_id, "sub" => user.id}
        {:ok, JWT.generate_and_sign!(claims)}

      {:error, :invalid} ->
        {:error, @error_detail[:invalid_client]}

      {:error, :invalid_code} ->
        {:error, @error_detail[:invalid_code]}

      {:error, :user_blocked} ->
        {:error, @error_detail[:user_blocked]}
    end
  end

  def create_access_token(%{
        grant_type: "client_credentials",
        client_id: client_id,
        client_secret: client_secret
      }) do
    req = %Request{identifier: %{id: client_id}, data: %{secret: client_secret}}

    case BillionOak.verify_client(req) do
      {:ok, client} ->
        claims = %{"aud" => client.id, "sub" => "anon_" <> XCUID.generate()}
        {:ok, JWT.generate_and_sign!(claims)}

      {:error, _} ->
        {:error, @error_detail[:invalid_client]}
    end
  end

  defp get_openid(client, code) do
    wx_url = "https://api.weixin.qq.com/sns/jscode2session"

    params = %{
      appid: client.wx_app_id,
      secret: client.wx_app_secret,
      js_code: code,
      grant_type: "authorization_code"
    }

    Req.get(wx_url, params: params)
    ~> Map.get(:body)
    ~> Jason.decode!()
    ~>> parse_wx_error()
    ~> Map.get("openid")
  end

  defp parse_wx_error(%{"errcode" => 40029}), do: {:error, :invalid_code}
  defp parse_wx_error(%{"errcode" => 40226}), do: {:error, :user_blocked}
  defp parse_wx_error(%{"errcode" => 45011}), do: {:error, :busy}
  defp parse_wx_error(%{"errcode" => _}), do: {:error, :unavailable}
  defp parse_wx_error(noerror), do: {:ok, noerror}
end
