defmodule BillionOakWeb.Router do
  use BillionOakWeb, :router

  get "/", BillionOakWeb.WelcomeController, :show

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BillionOakWeb do
    pipe_through :api
  end

  pipeline :authenticated do
    plug BillionOakWeb.Plugs.UnwrapAccessToken
    plug BillionOakWeb.Plugs.EnsureAuthenticated
  end

  scope "/v1", BillionOakWeb do
    post "/token", TokenController, :create
  end

  scope "/v1" do
    pipe_through :authenticated
    forward "/graphql", Absinthe.Plug, schema: BillionOakWeb.Schema
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:billion_oak, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BillionOakWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
      forward "/graphiql", Absinthe.Plug.GraphiQL, schema: BillionOakWeb.Schema
    end
  end
end
