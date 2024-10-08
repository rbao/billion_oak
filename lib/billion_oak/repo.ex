defmodule BillionOak.Repo do
  use Ecto.Repo,
    otp_app: :billion_oak,
    adapter: Ecto.Adapters.Postgres
end
