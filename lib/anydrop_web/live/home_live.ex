defmodule AnydropWeb.HomeLive do
  alias Anydrop.DropContext.Drop
  use AnydropWeb, :live_view
  alias Anydrop.DropContext

  def render(assigns) do
    ~H"""
    <div class="grid w-full min-h-full">
      <div
        class="bg-repeat opacity-20 row-start-1 col-start-1 -z-10"
        style="background-image: url(/images/bg/doodles.png)"
      />
      <div class="container max-w-2xl px-4 justify-self-center row-start-1 col-start-1">
        <div class="flex rounded-full h-16 w-16 bg-white shadow-2xl justify-center items-center mx-auto mt-16 p-3 transition-all duration-500 ring-1 ring-zinc-700 hover:ring-2 shadow-lg hover:shadow-md mb-32 overflow-hidden">
          <svg
            width="256"
            height="256"
            viewBox="0 0 256 256"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <rect width="256" height="256" fill="white" fill-opacity="0.01" />
            <path
              d="M95 185H29L62 242H128L95 185Z"
              fill="#1E293B"
              stroke="white"
              stroke-width="5"
              stroke-linejoin="round"
            />
            <path
              d="M128 14L29 185H95L194 14H128Z"
              fill="#1E293B"
              stroke="white"
              stroke-width="5"
              stroke-linejoin="round"
            />
            <path d="M227 185L194 128L161 185H227Z" fill="#334155" stroke="white" stroke-width="5" />
            <path
              d="M194 14L227 71L128 242L95 185L194 14Z"
              fill="#334155"
              stroke="white"
              stroke-width="5"
              stroke-linejoin="round"
            />
          </svg>
        </div>
        <.simple_form for={@form} id="drop_form" phx-submit="save" phx-change="validate">
          <.input
            type="textarea"
            field={@form[:body]}
            label="Short Message (max 500 chars)"
            class="h-36 py-6 px-7 scroll-p-6 border-0 resize-none leading-6 text-zinc-700 focus:text-zinc-900 hover:text-zinc-900 font-medium text-lg ring-1 ring-zinc-700 hover:ring-2 focus:ring-2 focus:ring-offset-4 focus:ring-offset-zinc-200 focus:ring-zinc-700 shadow-lg hover:shadow-md focus:shadow-none bg-white transition-all duration-500 placeholder-zinc-500"
            placeholder="Write your message here..."
            maxlength="500"
            phx-mounted={JS.focus()}
            phx-debounce="1000"
            required
          />
          <div class="flex justify-end">
            <button
              disable-with="Dropping..."
              class="bg-white inline-flex items-center justify-center whitespace-nowrap rounded-md
                        text-sm font-medium ring-offset-background transition-all duration-500
                        h-10 px-8 py-4
                        text-zinc-700 hover:text-zinc-900
                        fill-zinc-700 hover:fill-zinc-900
                        shadow-lg hover:shadow-md focus:shadow-none bg-white
                        ring-1 ring-zinc-700 hover:ring-zinc-900 focus:ring-zinc-900 hover:ring-2 focus:ring-offset-4 focus:ring-offset-zinc-200
                        select-none
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
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, :page_title, "AnyDrop - Drop anonymous messages!")
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
