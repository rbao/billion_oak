defmodule Mix.Tasks.Bo.Ht.Ingest do
  use Mix.Task
  alias BillionOak.Request

  @shortdoc "Ingest happy team data"

  @moduledoc """
  This is where we would put any long form documentation and doctests.
  """
  @requirements ["app.start"]
  @impl Mix.Task
  def run(_args) do
    BillionOak.Ingestion.Mannatech.ingest("happyteam")
    |> IO.inspect()
  end
end
