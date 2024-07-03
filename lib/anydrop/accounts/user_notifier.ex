defmodule Anydrop.Accounts.UserNotifier do
  import Swoosh.Email

  alias Anydrop.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Anydrop", "no-reply@audacioustux.com"})
      |> subject(subject)
      |> html_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def deliver_login_instructions(email, url, otp) do
    deliver(email, "Login instructions", """

    Hi,

    You can confirm your account by visiting the URL below:

    <div style="text-align: center;">
      <a href="#{url}" style="font-size: 32px; margin: auto; text-decoration: underline;">Confirm Login</a>
    </div>
    or, copy and paste the OTP:
    <div style="border: 2px solid #000; padding: 10px; text-align: center; max-width: 200px; margin: auto;">
      <p style="font-weight: bold; font-size: 24px;">#{otp}</p>
    </div>
    or, copy and paste the link in your browser:

    <p style="width: 50%; text-decoration: none;">#{url}</p>

    If you didn't create an account with us, please ignore this.
    """)
  end
end
