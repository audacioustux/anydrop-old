defmodule AnydropWeb.UserSessionController do
  use AnydropWeb, :controller

  alias Anydrop.Accounts
  alias AnydropWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"token" => token, "otp" => otp}) do
    case Accounts.verify_login_token(token, otp) do
      {:ok, %{"email" => email}} ->
        if user = Accounts.get_user_by_email(email) do
          conn
          |> put_flash(:info, "Welcome back!")
          |> UserAuth.log_in_user(user)
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

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email} = user_params

    user = Accounts.get_user_by_email(email)

    conn
    |> put_flash(:info, info)
    |> UserAuth.log_in_user(user)
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
