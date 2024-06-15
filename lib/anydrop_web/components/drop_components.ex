defmodule AnydropWeb.DropComponents do
  use Phoenix.Component
  import Phoenix.HTML
  import AnydropWeb.CoreComponents
  alias Phoenix.LiveView.JS

  # attr :body, :string, required: true
  # attr :created, :any, required: true
  attr :dom_id, :string, required: true
  attr :drop, Anydrop.DropContext.Drop, required: true
  attr :class, :string, default: ""

  def drop_card(assigns) do
    ~H"""
      <div id={@dom_id} class={["flex flex-col
                      rounded-lg shadow-lg bg-white
                      border-0
                      w-full
                      px-6 pt-5 pb-2
                      relative
                      group
                     ", @class]}
      >
        <%!-- <svg class="w-6 h-6 fill-zinc-600" stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M6.5 10c-.223 0-.437.034-.65.065.069-.232.14-.468.254-.68.114-.308.292-.575.469-.844.148-.291.409-.488.601-.737.201-.242.475-.403.692-.604.213-.21.492-.315.714-.463.232-.133.434-.28.65-.35l.539-.222.474-.197-.485-1.938-.597.144c-.191.048-.424.104-.689.171-.271.05-.56.187-.882.312-.318.142-.686.238-1.028.466-.344.218-.741.4-1.091.692-.339.301-.748.562-1.05.945-.33.358-.656.734-.909 1.162-.293.408-.492.856-.702 1.299-.19.443-.343.896-.468 1.336-.237.882-.343 1.72-.384 2.437-.034.718-.014 1.315.028 1.747.015.204.043.402.063.539l.025.168.026-.006A4.5 4.5 0 1 0 6.5 10zm11 0c-.223 0-.437.034-.65.065.069-.232.14-.468.254-.68.114-.308.292-.575.469-.844.148-.291.409-.488.601-.737.201-.242.475-.403.692-.604.213-.21.492-.315.714-.463.232-.133.434-.28.65-.35l.539-.222.474-.197-.485-1.938-.597.144c-.191.048-.424.104-.689.171-.271.05-.56.187-.882.312-.317.143-.686.238-1.028.467-.344.218-.741.4-1.091.692-.339.301-.748.562-1.05.944-.33.358-.656.734-.909 1.162-.293.408-.492.856-.702 1.299-.19.443-.343.896-.468 1.336-.237.882-.343 1.72-.384 2.437-.034.718-.014 1.315.028 1.747.015.204.043.402.063.539l.025.168.026-.006A4.5 4.5 0 1 0 17.5 10z"></path>
        </svg> --%>
        <p class=" line-clamp-4 leading-6
                  text-zinc-700 font-medium text-lg"
        >
          <%= @drop.body |> sanitze_body() %>
        </p>
        <%!-- <svg class="self-end w-6 h-6 fill-zinc-600" stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="m21.95 8.721-.025-.168-.026.006A4.5 4.5 0 1 0 17.5 14c.223 0 .437-.034.65-.065-.069.232-.14.468-.254.68-.114.308-.292.575-.469.844-.148.291-.409.488-.601.737-.201.242-.475.403-.692.604-.213.21-.492.315-.714.463-.232.133-.434.28-.65.35l-.539.222-.474.197.484 1.939.597-.144c.191-.048.424-.104.689-.171.271-.05.56-.187.882-.312.317-.143.686-.238 1.028-.467.344-.218.741-.4 1.091-.692.339-.301.748-.562 1.05-.944.33-.358.656-.734.909-1.162.293-.408.492-.856.702-1.299.19-.443.343-.896.468-1.336.237-.882.343-1.72.384-2.437.034-.718.014-1.315-.028-1.747a7.028 7.028 0 0 0-.063-.539zm-11 0-.025-.168-.026.006A4.5 4.5 0 1 0 6.5 14c.223 0 .437-.034.65-.065-.069.232-.14.468-.254.68-.114.308-.292.575-.469.844-.148.291-.409.488-.601.737-.201.242-.475.403-.692.604-.213.21-.492.315-.714.463-.232.133-.434.28-.65.35l-.539.222c-.301.123-.473.195-.473.195l.484 1.939.597-.144c.191-.048.424-.104.689-.171.271-.05.56-.187.882-.312.317-.143.686-.238 1.028-.467.344-.218.741-.4 1.091-.692.339-.301.748-.562 1.05-.944.33-.358.656-.734.909-1.162.293-.408.492-.856.702-1.299.19-.443.343-.896.468-1.336.237-.882.343-1.72.384-2.437.034-.718.014-1.315-.028-1.747a7.571 7.571 0 0 0-.064-.537z"></path>
        </svg> --%>
        <p class="self-end">
          <%!-- <span class="text-zinc-500 font-medium text-sm">Created at:</span> --%>
          <span class="text-zinc-600 font-medium text-xs"><%= @drop.inserted_at |> DateTime.to_date() %></span>
        </p>
        <button class="absolute z-20 peer invisible group-hover:visible right-6 top-3
                      text-red-500 font-semibold text-sm rounded-lg px-2
                      group-hover:bg-red-200"
                phx-click={JS.push("delete_drop", value: %{dom_id: @dom_id, drop_id: @drop.id})}
        >
            Delete
        </button>
        <button class="absolute left-0 bottom-0 w-full h-full rounded-lg font-semibold
                      text-transparent group-hover:text-white peer-hover:text-white
                      hover:bg-black/30 group-hover:bg-black/30 active:bg-black/40
                      "
                phx-click={show_modal("drop-modal-#{@drop.id}")}>
          Open Drop
        </button>
        <.modal id={"drop-modal-#{@drop.id}"}>
          <p class="leading-6
                    text-zinc-700 font-medium text-lg"
          >
            <%= @drop.body |> sanitze_body() %>
          </p>
        </.modal>
      </div>
    """
  end

  defp sanitze_body(body) do
    body
    |> html_escape()
    |> safe_to_string()
    |> String.trim_trailing()
    |> String.replace("\n", "<br>")
    |> raw()
  end
end
