defmodule AnydropWeb.HomeLive do
  alias Anydrop.DropContext.Drop
  use AnydropWeb, :live_view
  alias Anydrop.DropContext

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} id="drop_form" phx-submit="save" phx-change="validate" class="!bg-transparent">
      <div class="text-center mx-16">
        <p class="text-3xl font-bold text-emerald-700">Drop a Message!</p>
      </div>
      <.input type="textarea" field={@form[:body]}  class="h-64 !text-xl bg-[#E6E6E6] font-semibold" required  />
      <div class="flex justify-end">
        <button disable-with="Dropping..."
          class="bg-emerald-600 text-white text-xl font-bold rounded p-2 hover:bg-emerald-500 active:bg-emerald-700"
        >
          Drop
        </button>
      </div>
    </.simple_form>
    """
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, :page_title, "AnyDrop - Drop / Send anything anonymously")
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

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset =
          changeset
          |> Map.put(:action, :insert)
          |> to_form()
        {:noreply, assign(socket, :form, changeset)}
    end
  end
end
