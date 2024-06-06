defmodule AnydropWeb.HomeLive do
  alias Anydrop.DropContext.Drop
  use AnydropWeb, :live_view
  alias Anydrop.DropContext

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} id="drop_form" phx-submit="save" phx-change="validate">
      <div class="text-center mx-16">
        <p class="text-4xl font-bold text-emerald-700">Drop a Message!</p>
      </div>
      <.input
        type="textarea"
        field={@form[:body]}
        class="h-64 bg-emerald-50 font-semibold shadow-md p-4"
        required
      />
      <div class="flex justify-end">
        <button
          disable-with="Dropping..."
          class="bg-white inline-flex items-center justify-center whitespace-nowrap rounded-md
                        text-sm font-medium ring-offset-background transition-colors
                        focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring
                        focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50
                        h-10 px-8 py-4
                        text-slate-700 hover:text-slate-800 active:fill-text-900
                        fill-slate-700 hover:fill-slate-800 active:fill-slate-900
                        shadow-md bg-white hover:bg-slate-50 active:bg-slate-100
                      "
        >
          <svg
            class="mr-2 w-6 h-6"
            stroke-width="0"
            viewBox="0 0 16 16"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path d="M1 1.91L1.78 1.5L15 7.44899V8.3999L1.78 14.33L1 13.91L2.58311 8L1 1.91ZM3.6118 8.5L2.33037 13.1295L13.5 7.8999L2.33037 2.83859L3.6118 7.43874L9 7.5V8.5H3.6118Z">
            </path>
          </svg>
          Drop Now !
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
         |> assign(:form, DropContext.change_drop(%Drop{}) |> to_form)}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset =
          changeset
          |> Map.put(:action, :insert)
          |> to_form()

        {:noreply, assign(socket, :form, changeset)}
    end
  end
end
