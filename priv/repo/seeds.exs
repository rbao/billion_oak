# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     BillionOak.Repo.insert!(%BillionOak.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias BillionOak.Customer

{:ok, mannatech} = Customer.create_company(%{alias: "mannatech", name: "Mannatech"})

{:ok, _} =
  Customer.create_organization(%{
    company_id: mannatech.id,
    alias: "happyteam",
    name: "Happy Team",
    root_account_number: "1168402"
  })
