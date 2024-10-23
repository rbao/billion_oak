defmodule Mix.Tasks.Bo.Ht.Ingest do
  use Mix.Task
  alias BillionOak.Request

  @shortdoc "Ingest happy team data"
  @requirements ["app.start"]
  @impl Mix.Task
  def run(_args) do
    req = %Request{_role_: :sysops,identifier: %{handle: "happyteam"}}

    req
    |> BillionOak.ingest_external_data()
    |> IO.inspect()
  end
end
