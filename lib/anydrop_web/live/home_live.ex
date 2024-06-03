defmodule AnydropWeb.HomeLive do
  alias Anydrop.DropContext.Drop
  use AnydropWeb, :live_view
  alias Anydrop.DropContext

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} id="drop_form" phx-submit="save" phx-change="validate">
      <.input type="textarea" field={@form[:body]} label="Drop Anything" required />
      <button disable-with="Dropping..."> Drop </button>
    </.simple_form>
    """
  end

  def mount(_params, _session, socket) do
    changeset = DropContext.change_drop(%Drop{})
    {:ok, socket |> assign(form: to_form(changeset))}
  end

  def handle_event("validate", %{"drop" => drop_params}, socket) do
    changeset = DropContext.change_drop(%Drop{}, drop_params)
    {:noreply, socket |> assign(form: to_form(changeset))}
  end

  def handle_event("save", %{"drop" => drop_params}, socket) do
    case DropContext.create_drop(drop_params) do
      {:ok, _drop} ->
        {:noreply,
          socket
          |> put_flash(:info, "Dropped!")
          |> assign(:form, DropContext.change_drop(%Drop{}) |> to_form)
        }
      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
