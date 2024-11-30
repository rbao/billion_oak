defmodule Mix.Tasks.Bo.Ht.Invite do
  use Mix.Task

  @shortdoc "Create a invitation code for happy team associate"
  @requirements ["app.start"]
  @impl Mix.Task
  def run([company_account_rid, role]) do
    IO.inspect(BillionOak.Devop.ht_invite(company_account_rid, role))
  end
end
