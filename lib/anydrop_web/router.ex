defmodule AnydropWeb.Router do
  use AnydropWeb, :router

  import AnydropWeb.ProfileAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AnydropWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_profile
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AnydropWeb do
    pipe_through :browser

    live_session :mount_profile,
        on_mount: [{AnydropWeb.ProfileAuth, :mount_current_profile}] do
          live "/", HomeLive
          live "/drop/:send_to", SendLive
      end
  end

  # Other scopes may use custom stacks.
  # scope "/api", AnydropWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:anydrop, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AnydropWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AnydropWeb do
    pipe_through [:browser, :redirect_if_profile_is_authenticated]

    live_session :redirect_if_profile_is_authenticated,
      on_mount: [{AnydropWeb.ProfileAuth, :redirect_if_profile_is_authenticated}] do
      live "/users/register/:token", ProfileRegistrationLive, :new
      live "/users/log_in", ProfileLoginLive, :new
    end

    post "/users/log_in", ProfileSessionController, :create
  end

  scope "/", AnydropWeb do
    pipe_through [:browser, :require_authenticated_profile]

    live_session :require_authenticated_profile,
      on_mount: [{AnydropWeb.ProfileAuth, :ensure_authenticated}] do
      live "/drops", AdminLive
    end
  end

  scope "/", AnydropWeb do
    pipe_through [:browser]

    delete "/users/log_out", ProfileSessionController, :delete

    # live_session :current_profile,
    #   on_mount: [{AnydropWeb.ProfileAuth, :mount_current_profile}] do

    # end
  end
end
