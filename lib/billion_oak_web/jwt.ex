defmodule BillionOakWeb.JWT do
  use Joken.Config, default_signer: :rs256

  @impl true
  def token_config do
    default_claims(skip: [:aud, :jti, :nbf, :iss, :iat])
  end
end
