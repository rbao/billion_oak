defmodule Mix.Tasks.Bo.Ht.Client do
  use Mix.Task

  @shortdoc "Get happy team WeChat miniprogram client"
  @requirements ["app.start"]
  @impl Mix.Task
  def run(_args) do
    IO.inspect(BillionOak.Devop.all_clients())
  end
end
