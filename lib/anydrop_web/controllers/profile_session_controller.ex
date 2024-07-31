defmodule AnydropWeb.ProfileSessionController do
  use AnydropWeb, :controller

  alias Anydrop.Accounts
  alias AnydropWeb.ProfileAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"token" => token, "otp" => otp}) do
    case Accounts.verify_login_token(token, otp) do
      {:ok, %{"email" => email}} ->
        if profile = Accounts.get_profile_by_email(email) do
          conn
          |> put_flash(:info, "Welcome back!")
          |> ProfileAuth.log_in_profile(profile)
        else
          reg_token = Accounts.create_registration_token(email)
          conn
          |> put_flash(:email, email)
          |> redirect(to: ~p"/users/register/#{reg_token}")
        end
      {:error, _} ->
        conn
        |> put_flash(:error, "Invalid/Expired token or OTP")
        |> redirect(to: ~p"/users/log_in")
    end
  end

  defp create(conn, %{"profile" => profile_params}, info) do
    %{"email" => email} = profile_params

    profile = Accounts.get_profile_by_email(email)

    conn
    |> put_flash(:info, info)
    |> ProfileAuth.log_in_profile(profile)
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> ProfileAuth.log_out_profile()
  end
end
