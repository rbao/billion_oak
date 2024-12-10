# BillionOak

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Generate Keys

```
$ mkdir keys/dev
$ cd keys/dev
$ openssl genrsa -out jwt_private.pem 2048
$ openssl rsa -in jwt_private.pem -outform PEM -pubout -out jwt_public.pem
```

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


```
fly ssh console --pty -C "/app/bin/billion_oak remote"
``