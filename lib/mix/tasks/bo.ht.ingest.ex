defmodule Mix.Tasks.Bo.Ht.Ingest do
  use Mix.Task

  @shortdoc "Ingest happy team data"
  @requirements ["app.start"]
  @impl Mix.Task
  def run(_args) do
    IO.inspect(BillionOak.Devop.ht_ingest())
  end
end
