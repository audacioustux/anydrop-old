defmodule AnydropWeb.UserLoginLive do
  use AnydropWeb, :live_view

  alias Anydrop.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <%= cond do %>
        <% @page == :email_form -> %>
          <.simple_form for={@form} id="form_for_email" phx-submit="submit_email">
            <.input field={@form[:email]} type="email" label="Email" required />
            <:actions>
              <.button phx-disable-with="Submit..." class="w-full">
                Submit <span aria-hidden="true">→</span>
              </.button>
            </:actions>
          </.simple_form>
        <% @page == :otp_form -> %>
          <.simple_form for={@form} id="form_for_otp"  phx-submit="submit_otp"
                            action={~p"/users/log_in?token=#{@token}&otp=#{@otp}"}
                            method="post"
                            phx-trigger-action={@trigger_submit}
          >
            <.input field={@form[:otp]} type="text" label="OTP" required />
            <:actions>
              <.button phx-disable-with="Logging in..." class="w-full">
                Log in <span aria-hidden="true">→</span>
              </.button>
            </:actions>
          </.simple_form>
        <% true -> %>
          <.simple_form for={@form} id="redirecting"
                            action={~p"/users/log_in?token=#{@token}&otp=#{@otp}"}
                            method="post"
                            phx-trigger-action={@trigger_submit}
          >
            redirecting...
          </.simple_form>
      <% end %>
    </div>
    """
  end

  def mount(%{"token" => token, "otp" => otp}, _session, socket) do
    form = to_form(%{"email" => "", "otp" => otp})
    {:ok, socket
            |> assign(:trigger_submit, true)
            |> assign(form: form)
            |> assign(:page, :none)
            |> assign(:token, token)
            |> assign(:otp, otp)
    }
  end

  def mount(_params, _session, socket) do
    form = to_form(%{"email" => "", "otp" => ""})
    socket =
      socket
      |> assign(page: :email_form)
      |> assign(form: form)
      |> assign(token: "")
      |> assign(otp: "")
      |> assign(trigger_submit: false)
    {:ok, socket, temporary_assigns: [form: form]}
  end

  def handle_event("submit_email", %{"email" => email}, socket) do
    token = Accounts.create_login_token_and_deliver_instruction(email)
    socket =
      socket
      |> put_flash(:info, "instruction sent to your email.")
      |> assign(:page, :otp_form)
      |> assign(:token, token)
    {:noreply, socket}
  end

  def handle_event("submit_otp", %{"otp" => otp}, socket) do
    socket =
      socket
      |> assign(:otp, otp)
      |> assign(:trigger_submit, true)
    {:noreply, socket}
  end
end
