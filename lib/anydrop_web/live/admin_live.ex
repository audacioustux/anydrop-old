defmodule AnydropWeb.AdminLive do
  use AnydropWeb, :live_view
  import AnydropWeb.DropComponents

  alias Anydrop.DropContext

  def render(assigns) do
    ~H"""
      <main class="container flex flex-col items-start gap-12 max-w-2xl py-16 mx-auto px-4">
        <%= for drop <- @drops do%>
          <.drop_card
            body={drop.body}
            created={drop.inserted_at}
          />
        <% end %>
      </main>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: DropContext.subscribe()
    socket = assign(socket, :page_title, "AnyDrop - Drop / Send anything anonymously")
    drops = DropContext.list_drops()
    {:ok, socket |> assign(drops: drops)}
  end

  def handle_info({:message_dropped, drop}, socket) do
    socket =
      update(socket, :drops, fn drops ->
        drops ++ [drop]
      end)
    {:noreply, socket}
  end

end
