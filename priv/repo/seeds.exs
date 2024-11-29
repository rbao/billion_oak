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

alias BillionOak.Request

{:ok, %{data: mannatech}} =
  BillionOak.create_company(%Request{
    _role_: :sysops,
    data: %{handle: "mannatech", name: "Mannatech"}
  })

{:ok, %{data: happyteam}} =
  BillionOak.create_organization(%Request{
    _role_: :sysops,
    data: %{
      company_id: mannatech.id,
      handle: "happyteam",
      name: "Happy Team",
      root_company_account_rid: "1168402"
    }
  })

{:ok, _} =
  BillionOak.create_client(%Request{
    _role_: :sysops,
    data: %{
      name: "WeChat Mini Program",
      organization_id: happyteam.id,
      wx_app_id: System.get_env("HT_WX_APP_ID"),
      wx_app_secret: System.get_env("HT_WX_APP_SECRET")
    }
  })
