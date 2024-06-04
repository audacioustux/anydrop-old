defmodule AnydropWeb.HomeLive do
  alias Anydrop.DropContext.Drop
  use AnydropWeb, :live_view
  alias Anydrop.DropContext

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} id="drop_form" phx-submit="save" phx-change="validate" class="!bg-transparent">
      <div class="text-center mx-16">
        <p class="text-4xl font-bold text-emerald-700">Drop a Message!</p>
      </div>
      <.input type="textarea" field={@form[:body]}  class="h-64 !text-xl bg-[#E6E6E6] font-semibold" required  />
      <div class="flex justify-end">
        <button disable-with="Dropping..."
          class="
                rounded-md text-2xl font-medium leading-5 text-slate-700 hover:text-slate-800 active:fill-slate-900
                fill-slate-700 hover:fill-slate-800 active:fill-slate-900
                shadow-sm ring-1 ring-slate-700/10 bg-white hover:bg-slate-50 active:bg-slate-100
                "
        >
          <div class="flex items-center justify-around px-3 py-2">
            <svg class="mr-2 h-10 w-10 flex-none " stroke="currentColor" stroke-width="0" viewBox="0 0 32 32" height="200px" width="200px" xmlns="http://www.w3.org/2000/svg"><path d="M 28 16 C 28 9.382813 22.617188 4 16 4 C 9.382813 4 4 9.382813 4 16 L 4 16.453125 L 12 23.453125 L 12 28 L 20 28 L 20 23.453125 L 28 16.453125 Z M 16 6.363281 C 16.867188 7.304688 18.421875 9.535156 18.871094 13.65625 C 18.148438 13.28125 17.207031 13 16 13 C 14.792969 13 13.851563 13.28125 13.128906 13.65625 C 13.578125 9.53125 15.136719 7.300781 16 6.363281 Z M 11.085938 16.398438 L 13.484375 22 L 13.375 22 L 6.335938 15.839844 C 6.71875 15.449219 7.390625 15 8.5 15 C 10.402344 15 11.058594 16.351563 11.085938 16.398438 Z M 15.660156 22 L 13.140625 16.125 C 13.523438 15.691406 14.378906 15 16 15 C 17.625 15 18.484375 15.695313 18.859375 16.121094 L 16.339844 22 Z M 18.515625 22 L 20.914063 16.398438 C 20.925781 16.382813 21.554688 15 23.5 15 C 24.601563 15 25.273438 15.453125 25.660156 15.84375 L 18.625 22 Z M 25.660156 13.445313 C 25.078125 13.179688 24.367188 13 23.5 13 C 22.390625 13 21.535156 13.292969 20.878906 13.683594 C 20.535156 10.207031 19.46875 7.824219 18.476563 6.320313 C 21.976563 7.21875 24.738281 9.957031 25.660156 13.445313 Z M 13.519531 6.324219 C 12.53125 7.824219 11.464844 10.207031 11.121094 13.683594 C 10.464844 13.292969 9.609375 13 8.5 13 C 7.632813 13 6.921875 13.179688 6.339844 13.445313 C 7.261719 9.957031 10.023438 7.21875 13.519531 6.324219 Z M 18 26 L 14 26 L 14 24 L 18 24 Z"></path></svg>
            <span class="mr-1">Drop</span>
          </div>
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
