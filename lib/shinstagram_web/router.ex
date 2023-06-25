defmodule ShinstagramWeb.Router do
  use ShinstagramWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ShinstagramWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShinstagramWeb do
    pipe_through :browser

    live "/", PostLive.Index, :index

    live "/profiles", ProfileLive.Index, :index
    live "/profiles/new", ProfileLive.Index, :new
    live "/profiles/:username/edit", ProfileLive.Index, :edit
    live "/profiles/:username/show/edit", ProfileLive.Show, :edit
    live "/:username", ProfileLive.Show, :show

    live "/posts", PostLive.Index, :index
    live "/posts/new", PostLive.Index, :new
    live "/posts/:id/edit", PostLive.Index, :edit

    live "/posts/:id", PostLive.Show, :show
    live "/posts/:id/show/edit", PostLive.Show, :edit

    live "/likes", LikeLive.Index, :index
    live "/likes/new", LikeLive.Index, :new
    live "/likes/:id/edit", LikeLive.Index, :edit

    live "/likes/:id", LikeLive.Show, :show
    live "/likes/:id/show/edit", LikeLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShinstagramWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:shinstagram, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ShinstagramWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
