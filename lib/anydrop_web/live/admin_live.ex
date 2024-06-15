defmodule AnydropWeb.AdminLive do
  use AnydropWeb, :live_view
  import AnydropWeb.DropComponents

  alias Anydrop.DropContext

  def render(assigns) do
    ~H"""
      <div id="scroll-wrapper-id" phx-hook="ScrollToBottom">
        <main id="drops-container"
          phx-update="stream"
          phx-viewport-top={!@end_of_stream? && "prev-page"}
          phx-viewport-bottom={@page > 1 && "next-page"}
          phx-loading-page
          class={["container flex flex-col items-start gap-12 max-w-2xl py-16 mx-auto px-4",
                  if(@end_of_stream?, do: "", else: "pt-[calc(200vh)]"),
                  if(@page == 1, do: "", else: "pb-[calc(200vh)]")
          ]}
        >
          <%= for {id, drop} <- @streams.drops do%>
            <.drop_card
              drop={drop}
              dom_id={id}
            />
          <% end %>
        </main>
      </div>

      <%= if @new_drop? do%>
        <button id="scroll-button" phx-click="load_latest_drops_and_scroll-to-bottom" class="fixed bottom-[10%] right-[10%] bg-emerald-200 p-4">
          new message
        </button>
      <% end %>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: DropContext.subscribe()

    socket =
      socket
      |> assign(:page_title, "AnyDrop - Drop / Send anything anonymously")
      |> assign(page: 1, per_page: 10)
      |> assign(:new_drop?, false)
      |> paginate_drops(1)

      {:ok, socket}

  end

  defp paginate_drops(socket, new_page) when new_page >= 1 do
    %{per_page: per_page, page: cur_page} = socket.assigns
    drops = DropContext.list_drops(offset: (new_page - 1) * per_page, limit: per_page)

    {drops, at, limit} =
      if new_page <= cur_page do
        {Enum.reverse(drops), -1, per_page*3*-1}
      else
        {drops, 0, per_page*3*1}
      end

    case drops do
      [] ->
        assign(socket, end_of_stream?: at == 0)

      [_ | _] ->
        socket
        |> assign(end_of_stream?: false)
        |> assign(page: new_page)
        |> stream(:drops, drops, at: at, limit: limit)
    end
  end


  def handle_event("next-page", _, socket) do
    {:noreply, socket |> paginate_drops(socket.assigns.page - 1)}
  end

  def handle_event("prev-page", %{"_overran" => true}, socket) do
    {:noreply, paginate_drops(socket, 1)}
  end

  def handle_event("prev-page", _, socket) do
    if socket.assigns.page >= 1 do
      {:noreply, socket |> paginate_drops( socket.assigns.page + 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("load_latest_drops_and_scroll-to-bottom", _params, socket) do
    socket = assign(socket, :new_drop?, false)
    {:noreply,
      socket
      |> stream(:drops, [], reset: true)
      |> paginate_drops(1)
      |> push_event("scroll-to-bottom", %{})
      |> assign(:new_drop?, false)
    }
  end

  def handle_event("delete_drop", %{"dom_id" => dom_id, "drop_id" => drop_id}, socket) do
    drop = DropContext.get_drop!(drop_id)
    DropContext.update_is_deleted_drop(drop)
    socket = stream_delete_by_dom_id(socket, :drops, dom_id)
    {:noreply, socket}
  end

  def handle_info({:message_dropped, _drop}, socket) do
    socket = assign(socket, :new_drop?, true)
    {:noreply, socket}
  end

end
