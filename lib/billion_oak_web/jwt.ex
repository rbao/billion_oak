defmodule BillionOakWeb.JWT do
  use Joken.Config, default_signer: :rs256

  @impl true
  def token_config do
    default_claims(skip: [:aud], iss: "billion_oak_web")
  end
end
