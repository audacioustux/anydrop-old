defmodule AnydropWeb.ProfileLoginLive do
  use AnydropWeb, :live_view

  alias Anydrop.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto pt-4 lg:pt-24 max-w-lg px-4">
      <%= cond do %>
        <% @page == :email_form -> %>
          <.simple_form for={@form} id="form_for_email" phx-submit="submit_email">
            <.input field={@form[:email]} type="email" label="Email" required
                class="h-36 py-6 px-7 scroll-p-6 border-0 resize-none leading-6 text-zinc-700 focus:text-zinc-900 hover:text-zinc-900 font-medium text-lg ring-1 ring-zinc-700 hover:ring-2 focus:ring-2 focus:ring-offset-4 focus:ring-offset-zinc-200 focus:ring-zinc-700 shadow-lg hover:shadow-md focus:shadow-none bg-white transition-all duration-500 placeholder-zinc-500"
            />
            <:actions>
              <button phx-disable-with="Submitting..." class="bg-white inline-flex items-center justify-center whitespace-nowrap rounded-md
                        text-sm font-medium ring-offset-background transition-all duration-500
                        h-10 px-8 py-4
                        text-zinc-700 hover:text-zinc-900
                        fill-zinc-700 hover:fill-zinc-900
                        shadow-lg hover:shadow-md focus:shadow-none
                        ring-1 ring-zinc-700 hover:ring-zinc-900 focus:ring-zinc-900 hover:ring-2 focus:ring-offset-4 focus:ring-offset-zinc-200
                        select-none
                        w-full
                        lg:w-1/3">
                Submit <span aria-hidden="true">→</span>
              </button>
            </:actions>
          </.simple_form>
        <% @page == :otp_form -> %>
          <.simple_form for={@form} id="form_for_otp"  phx-submit="submit_otp"
                            action={~p"/users/log_in?token=#{@token}&otp=#{@otp}"}
                            method="post"
                            phx-trigger-action={@trigger_submit}
          >
            <.input field={@form[:otp]} type="text" label="OTP" required
                class="h-36 py-6 px-7 scroll-p-6 border-0 resize-none leading-6 text-zinc-700 focus:text-zinc-900 hover:text-zinc-900 font-medium text-lg ring-1 ring-zinc-700 hover:ring-2 focus:ring-2 focus:ring-offset-4 focus:ring-offset-zinc-200 focus:ring-zinc-700 shadow-lg hover:shadow-md focus:shadow-none bg-white transition-all duration-500 placeholder-zinc-500"
            />
            <:actions>
              <button phx-disable-with="Logging in..." class="bg-white inline-flex items-center justify-center whitespace-nowrap rounded-md
                        text-sm font-medium ring-offset-background transition-all duration-500
                        h-10 px-8 py-4
                        text-zinc-700 hover:text-zinc-900
                        fill-zinc-700 hover:fill-zinc-900
                        shadow-lg hover:shadow-md focus:shadow-none
                        ring-1 ring-zinc-700 hover:ring-zinc-900 focus:ring-zinc-900 hover:ring-2 focus:ring-offset-4 focus:ring-offset-zinc-200
                        select-none
                        w-full
                        lg:w-1/3">
                Log in <span aria-hidden="true">→</span>
              </button>
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
