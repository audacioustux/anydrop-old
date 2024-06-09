defmodule AnydropWeb.AdminLive do
  use AnydropWeb, :live_view
  import AnydropWeb.DropComponents

  alias Anydrop.DropContext

  def render(assigns) do
    ~H"""
      <main id="drops"
        phx-hook="ScrollToBottom"
        phx-update="stream"
        phx-viewport-top={!@end_of_stream? && "prev-page"}
        phx-viewport-bottom={@page > 1 && "next-page"}
        phx-page-loading
        class={["container relative flex flex-col items-start gap-12 max-w-2xl py-16 mx-auto px-4",
                if(@end_of_stream? || @first_mount, do: "", else: "pt-[calc(200vh)]"),
                if(@page == 1, do: "", else: "pb-[calc(200vh)]")
        ]}
      >
      <%= for {id, drop} <- @streams.drops do%>
        <.drop_card
          id={id}
          body={drop.body}
          created={drop.inserted_at}
        />
      <% end %>

      <%= if @new_drop? do%>
        <button phx-click="scroll-to-bottom" class="fixed bottom-[10%] right-[10%] bg-emerald-200 p-4">
          new message
        </button>
      <% end %>
      </main>
      <script>
        window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
      </script>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: DropContext.subscribe()
    # socket = assign(socket, :page_title, "AnyDrop - Drop / Send anything anonymously")
    # # drops = DropContext.list_drops()
    # # {:ok, socket |> assign(drops: drops)}
    # drops = DropContext.list_drops(offset: 1, limit: 10)
    # {:ok, stream(socket, :drops, Enum.reverse(drops), at: 0)}

    {:ok,
      socket
      |> assign(:page_title, "AnyDrop - Drop / Send anything anonymously")
      |> assign(page: 1, per_page: 10)
      |> assign(:first_mount, true)
      |> assign(:new_drop?, false)
      |> paginate_drops(1)
    }
  end

  defp paginate_drops(socket, new_page) when new_page >= 1 do
    %{per_page: per_page, page: cur_page} = socket.assigns
    drops = DropContext.list_drops(offset: (new_page - 1) * per_page, limit: per_page)

    {drops, at, limit} =
      cond do
        new_page == cur_page ->
          {Enum.reverse(drops), -1, per_page*3*-1}

        new_page > cur_page ->
          {drops, 0, per_page*3*1}
        true ->
          {Enum.reverse(drops), -1, per_page*3*-1}
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
    # {:ok, stream_insert(socket, :drops, Enum.reverse(drops), at: 0)}
  end


  def handle_event("next-page", _, socket) do
    {:noreply, socket |> assign(:first_mount, false) |> paginate_drops(socket.assigns.page - 1)}
  end

  def handle_event("prev-page", %{"_overran" => true}, socket) do
    {:noreply, paginate_drops(socket, 1)}
  end

  def handle_event("prev-page", _, socket) do
    if socket.assigns.page >= 1 do
      {:noreply, socket |> assign(:first_mount, false) |> paginate_drops( socket.assigns.page + 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("scroll-to-bottom", _params, socket) do
    # push_event(socket, "scroll-to-bottom", %{})
    # #drops = DropContext.list_drops(offset: 0, limit: socket.assigns.per_page)

    # # socket =
    # #   socket
    # #   |> assign(:new_drop?, false)
    # #   # |> stream(:drops, [], reset: true)
    # #   |> stream(:drops, drops, at: 0, limit: socket.assigns.per_page)
    # # {:noreply, socket}

    # {:noreply,
    #   socket
    #   |> assign(page: 1, per_page: 10)
    #   |> assign(:first_mount, true)
    #   |> assign(:new_drop?, false)
    #   |> stream(:drops, [], reset: true)
    #   |> paginate_drops(1)
    # }
    {:noreply, redirect(socket, to: ~p"/9a2ba138ad23cf439dc6b82696ab5a645cdbec18")}
  end

  def handle_info({:message_dropped, _drop}, socket) do
    socket = assign(socket, :new_drop?, true)
    push_event(socket, "play-sound", %{})
      # stream_insert(
      #   socket,
      #   :drops,
      #   drop,
      #   at: -1
      # )
    {:noreply, socket}
  end


end
