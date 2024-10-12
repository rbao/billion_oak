ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(BillionOak.Repo, :manual)
Faker.start()
{:ok, _} = Application.ensure_all_started(:ex_machina)
