import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :billion_oak, BillionOak.Repo,
  username: "roy",
  password: "",
  hostname: "localhost",
  database: "billion_oak_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :billion_oak, BillionOakWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "XqrkaO1EdGpJ2K3yeQuhIdMfd0++1dcKiEBLYSxVTCRmOqlrcuTBQ8hZTEsDIqL0",
  server: false

# In test we don't send emails
config :billion_oak, BillionOak.Mailer, adapter: Swoosh.Adapters.Test

config :billion_oak, BillionOak.Filestore.Client, BillionOak.Filestore.ClientMock
config :billion_oak, BillionOak.Content.FFmpeg, BillionOak.Content.FFmpegMock

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
