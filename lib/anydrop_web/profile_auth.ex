defmodule AnydropWeb.ProfileAuth do
  use AnydropWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Anydrop.Accounts

  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60
  @remember_me_cookie "_anydrop_web_remember_me"
  @remember_me_options [sign: true, http_only: true, secure: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Logs the profile in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_profile(conn, profile) do
    token = Accounts.create_profile_token(profile)
    profile_return_to = get_session(conn, :profile_return_to)

    conn
    |> put_token_in_cookie(token)
    |> put_session(:profile_token, token)
    |> put_session(:live_socket_id, "profiles_sessions:#{Base.url_encode64(token)}")
    |> redirect(to: profile_return_to || signed_in_path(conn))
  end

  defp put_token_in_cookie(conn, token) do
    conn
      |> put_resp_cookie(@remember_me_cookie, token, @remember_me_options)
  end

  # defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
  #   put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  # end

  # defp maybe_write_remember_me_cookie(conn, _token, _params) do
  #   conn
  # end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    delete_csrf_token()

    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the profile out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_profile(conn) do
    conn = fetch_cookies(conn, signed: @remember_me_cookie)
    # profile_token = get_session(conn, :profile_token)
    # profile_token && Accounts.delete_profile_session_token(profile_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      AnydropWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie, @remember_me_options)
    |> redirect(to: ~p"/")
  end

  @doc """
  Authenticates the profile by looking into the session
  and remember me token.
  """
  def fetch_current_profile(conn, _opts) do
    {profile_token, conn} = ensure_profile_token(conn)
    profile = profile_token && Accounts.get_profile_by_profile_token(profile_token)
    assign(conn, :current_profile, profile)
  end

  defp ensure_profile_token(conn) do
    if token = get_session(conn, :profile_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, put_session(conn, :profile_token, token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  Handles mounting and authenticating the current_profile in LiveViews.

  ## `on_mount` arguments

    * `:mount_current_user` - Assigns current_user
      to socket assigns based on user_token, or nil if
      there's no user_token or no matching user.

    * `:ensure_authenticated` - Authenticates the user from the session,
      and assigns the current_user to socket assigns based
      on user_token.
      Redirects to login page if there's no logged user.

    * `:redirect_if_user_is_authenticated` - Authenticates the user from the session.
      Redirects to signed_in_path if there's a logged user.

  ## Examples

  Use the `on_mount` lifecycle macro in LiveViews to mount or authenticate
  the current_user:

      defmodule AnydropWeb.PageLive do
        use AnydropWeb, :live_view

        on_mount {AnydropWeb.UserAuth, :mount_current_user}
        ...
      end

  Or use the `live_session` of your router to invoke the on_mount callback:

      live_session :authenticated, on_mount: [{AnydropWeb.UserAuth, :ensure_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  def on_mount(:mount_current_profile, _params, session, socket) do
    {:cont, mount_current_profile(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_profile(socket, session)

    if socket.assigns.current_profile do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/users/log_in")

      {:halt, socket}
    end
  end

  def on_mount(:redirect_if_profile_is_authenticated, _params, session, socket) do
    socket = mount_current_profile(socket, session)

    if socket.assigns.current_profile do
      {:halt, Phoenix.LiveView.redirect(socket, to: signed_in_path(socket))}
    else
      {:cont, socket}
    end
  end

  defp mount_current_profile(socket, session) do
    Phoenix.Component.assign_new(socket, :current_profile, fn ->
      if profile_token = session["profile_token"] do
        Accounts.get_profile_by_profile_token(profile_token)
      end
    end)
  end

  @doc """
  Used for routes that require the profile to not be authenticated.
  """
  def redirect_if_profile_is_authenticated(conn, _opts) do
    if conn.assigns[:current_profile] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the profile to be authenticated.

  If you want to enforce the profile email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_profile(conn, _opts) do
    if conn.assigns[:current_profile] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/users/log_in")
      |> halt()
    end
  end

  # defp put_token_in_session(conn, token) do
  #   conn
  #   |> put_session(:user_token, token)
  #   |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
  # end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :profile_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/"
end
