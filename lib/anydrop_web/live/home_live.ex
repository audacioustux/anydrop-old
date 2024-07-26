defmodule AnydropWeb.HomeLive do
  use AnydropWeb, :live_view

  def render(assigns) do
    ~H"""
    <%= if @current_profile do%>
      <div class="flex justify-between max-w-2xl px-4 pt-2 mx-auto lg:max-w-full lg:px-16">
        <.link href="#"> <%= @current_profile.display_name %> </.link>
        <.link
        href={~p"/users/log_out"}
        method="delete"
        class=" leading-6 text-brand_text font-semibold hover:text-brand_text_hover"
        >
          Log out
        </.link>
      </div>

      <div class="flex flex-col gap-4 p-8
                  lg:flex-row lg:justify-center lg:mx-auto lg:gap-x-8
                "
      >
        <button
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
          Share Link
        </button>

        <.link navigate={~p"/drops"}
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
          My Drops
        </.link>
      </div>

    <% else %>
      <p class="text-xl text-center"> Welcome to Anydrop </p>
      <div class="flex flex-col gap-4 p-8
                  lg:flex-row lg:justify-between lg:mx-auto lg:gap-x-8 lg:max-w-lg
                "
      >
        <.link navigate={~p"/users/log_in"}
          class="bg-white inline-flex items-center justify-center whitespace-nowrap rounded-md
                    text-sm font-medium ring-offset-background transition-all duration-500
                    h-10 px-8 py-4
                    text-zinc-700 hover:text-zinc-900
                    fill-zinc-700 hover:fill-zinc-900
                    shadow-lg hover:shadow-md focus:shadow-none bg-white
                    ring-1 ring-zinc-700 hover:ring-zinc-900 focus:ring-zinc-900 hover:ring-2 focus:ring-offset-4 focus:ring-offset-zinc-200
                    select-none
                    lg:w-1/2
                  "
        >
          Get Started
        </.link>

        <button
          class="bg-white inline-flex items-center justify-center whitespace-nowrap rounded-md
                    text-sm font-medium ring-offset-background transition-all duration-500
                    h-10 px-8 py-4
                    text-zinc-700 hover:text-zinc-900
                    fill-zinc-700 hover:fill-zinc-900
                    shadow-lg hover:shadow-md focus:shadow-none bg-white
                    ring-1 ring-zinc-700 hover:ring-zinc-900 focus:ring-zinc-900 hover:ring-2 focus:ring-offset-4 focus:ring-offset-zinc-200
                    select-none
                    lg:w-1/2
                  "
        >
          Send drops now
        </button>
      </div>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
