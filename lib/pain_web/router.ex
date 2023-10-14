defmodule PainWeb.Router do
  use PainWeb, :router

  import Surface.Catalogue.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PainWeb.Layouts, :root}
    plug Plug.CSRFProtection, allow_hosts: [
      "//assemble.codes",
      "//painawayofphilly.com",
      "//www.painawayofphilly.com",
      "//dove-caribou-3986.squarespace.com",

      "ws://assemble.codes",
      "ws://painawayofphilly.com",
      "ws://www.painawayofphilly.com",
      "ws://dove-caribou-3986.squarespace.com",

      "https://assemble.codes",
      "https://painawayofphilly.com",
      "https://www.painawayofphilly.com",
      "https://dove-caribou-3986.squarespace.com",
    ]
    plug :put_secure_browser_headers
    plug PainWeb.Plugs.EnableCors
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PainWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/book", BookLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", PainWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:pain, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PainWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through :browser
      surface_catalogue "/catalogue"
    end
  end
end
