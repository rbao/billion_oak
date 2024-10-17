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

alias BillionOak.{External, Identity}

{:ok, mannatech} = External.create_company(%{handle: "mannatech", name: "Mannatech"})

{:ok, happyteam} =
  Identity.create_organization(%{
    company_id: mannatech.id,
    handle: "happyteam",
    name: "Happy Team",
    root_company_account_rid: "1168402"
  })

{:ok, _} =
  Identity.create_client(%{
    name: "Wechat Mini Program",
    organization_id: happyteam.id
  })
