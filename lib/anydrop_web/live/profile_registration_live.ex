defmodule AnydropWeb.ProfileRegistrationLive do
  use AnydropWeb, :live_view

  alias Anydrop.Accounts
  alias Anydrop.Accounts.Profile

  def render(assigns) do
    ~H"""
    <div class="mx-auto pt-4 lg:pt-24 max-w-lg px-4">
      <.header> Finish creating your profile </.header>
      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input field={@form[:email]} type="email" label="Email" required readonly
          class="h-36 py-6 px-7 scroll-p-6 border-0 resize-none leading-6 text-zinc-700 focus:text-zinc-900 hover:text-zinc-900 font-medium text-lg ring-1 ring-zinc-700 hover:ring-2 focus:ring-2 focus:ring-offset-4 focus:ring-offset-zinc-200 focus:ring-zinc-700 shadow-lg hover:shadow-md focus:shadow-none bg-white transition-all duration-500 placeholder-zinc-500"
        />
        <.input field={@form[:handle]} type="text" label="Handle" required
          class="h-36 py-6 px-7 scroll-p-6 border-0 resize-none leading-6 text-zinc-700 focus:text-zinc-900 hover:text-zinc-900 font-medium text-lg ring-1 ring-zinc-700 hover:ring-2 focus:ring-2 focus:ring-offset-4 focus:ring-offset-zinc-200 focus:ring-zinc-700 shadow-lg hover:shadow-md focus:shadow-none bg-white transition-all duration-500 placeholder-zinc-500"
        />
        <.input field={@form[:display_name]} type="text" label="Display Name" required
          class="h-36 py-6 px-7 scroll-p-6 border-0 resize-none leading-6 text-zinc-700 focus:text-zinc-900 hover:text-zinc-900 font-medium text-lg ring-1 ring-zinc-700 hover:ring-2 focus:ring-2 focus:ring-offset-4 focus:ring-offset-zinc-200 focus:ring-zinc-700 shadow-lg hover:shadow-md focus:shadow-none bg-white transition-all duration-500 placeholder-zinc-500"
        />

        <:actions>
          <button phx-disable-with="Creating profile..." class="bg-white inline-flex items-center justify-center whitespace-nowrap rounded-md
                        text-sm font-medium ring-offset-background transition-all duration-500
                        h-10 px-8 py-4
                        text-zinc-700 hover:text-zinc-900
                        fill-zinc-700 hover:fill-zinc-900
                        shadow-lg hover:shadow-md focus:shadow-none
                        ring-1 ring-zinc-700 hover:ring-zinc-900 focus:ring-zinc-900 hover:ring-2 focus:ring-offset-4 focus:ring-offset-zinc-200
                        select-none
                        w-full
                        lg:w-1/3">Create a Profile</button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    email_from_flash = Phoenix.Flash.get(socket.assigns.flash, :email)
    email_from_token = Accounts.verify_registration_token(token)

    if email_from_flash == email_from_token do
      changeset = Accounts.change_profile_registration(%Profile{}, %{email: email_from_flash})

      socket =
        socket
        |> assign(trigger_submit: false, check_errors: false)
        |> assign_form(changeset)

      {:ok, socket, temporary_assigns: [form: nil]}
    else
      {:ok, socket |> put_flash(:error, "Access Denied") |> redirect(to: ~p"/users/log_in")}
    end

  end

  def handle_event("save", %{"profile" => profile_params}, socket) do
    display_name = clean_display_name(profile_params["display_name"])
    profile_params = Map.put(profile_params, "display_name", display_name)

    case Accounts.register_profile(profile_params) do
      {:ok, profile} ->
        changeset = Accounts.change_profile_registration(profile)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"profile" => profile_params}, socket) do
    changeset = Accounts.change_profile_registration(%Profile{}, profile_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "profile")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  defp clean_display_name(display_name) do
    display_name
      |> String.trim()
      |> String.replace(~r/\s+/, " ")
  end
end
