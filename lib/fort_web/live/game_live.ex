defmodule FortWeb.GameLive do
  alias Fort.Game

  use FortWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:active_page, :buildings)}
  end

  @impl true
  def handle_params(%{"page" => page}, _uri, socket) do
    {:noreply,
     socket
     |> assign(:active_page, page |> String.to_atom())
     |> assign(:game, %Game{})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-row">
      <.sidebar active_page={@active_page} />
      <.main active_page={@active_page} game={@game} />
    </div>
    """
  end

  attr :active_page, :atom, required: true
  attr :game, Game, required: true

  def main(assigns) do
    # - we could use TagEngine.component() to render target component dynamically,
    #   but it has a lot of params, so the call is not nicer
    # - in the future, these will probably be LiveComponents, so we'll be able to use the
    #   `live_component` macro

    ~H"""
    <div class="p-6">
      <div class="mb-6">
        <.resources resources={@game.resources} />
      </div>

      <%= case @active_page do %>
        <% :buildings -> %>
          <.buildings buildings={@game.buildings} />
        <% :upgrades -> %>
          <.upgrades />
        <% :army -> %>
          <.army />
      <% end %>
    </div>
    """
  end

  attr :it, :any, required: true

  def debug(assigns) do
    ~H"""
    <div class="my-4">
      <h3 class="text-lg font-semibold">debug</h3>
      <pre class="my-2"><%= inspect(@it, pretty: true) %></pre>
    </div>
    """
  end

  attr :resources, :map, required: true

  def resources(assigns) do
    ~H"""
    <div
      id="resources"
      class="w-[50vw] min-w-max flex flex-row justify-between gap-2 px-4 py-3 rounded-lg bg-zinc-100"
    >
      <div :for={{resource_type, amount} <- @resources}>
        <%= resource_type %>: <%= amount %>
      </div>
    </div>
    """
  end

  attr :buildings, :map, required: true

  def buildings(assigns) do
    ~H"""
    <div id="buildings" class="flex flex-col gap-2">
      <div :for={{building_type, amount} <- @buildings}>
        <%= building_type %>: <%= amount %>
      </div>
    </div>
    """
  end

  def upgrades(assigns) do
    ~H"""
    Tady budou upgrady
    """
  end

  def army(assigns) do
    ~H"""
    Tady bude armada
    """
  end

  attr :active_page, :atom, required: true

  def sidebar(assigns) do
    ~H"""
    <aside class="w-64 p-6 border-r">
      <nav class="space-y-8 text-sm">
        <div class="space-y-2">
          <h2 class="text-sm font-semibold tracking-widest uppercase dark:text-gray-400">
            Getting Started
          </h2>
          <div class="flex flex-col space-y-1">
            <a href="#">Installation</a>
            <a href="#">Plugins</a>
            <a href="#">Migrations</a>
          </div>
        </div>

        <div class="space-y-2">
          <h2 class="text-sm font-semibold tracking-widest uppercase dark:text-gray-400">Pages</h2>
          <div class="flex flex-col space-y-1">
            <.nav label="Buildings" page={:buildings} active_page={@active_page} />
            <.nav label="Upgrades" page={:upgrades} active_page={@active_page} />
            <.nav label="Army" page={:army} active_page={@active_page} />
          </div>
        </div>
      </nav>
    </aside>
    """
  end

  attr :label, :string, required: true
  attr :page, :atom, required: true
  attr :active_page, :atom, required: true

  def nav(assigns) do
    class = if assigns.page == assigns.active_page, do: "font-semibold", else: ""
    assigns = assign(assigns, :class, class)

    ~H"""
    <.link patch={~p"/game/#{@page}"} class={@class}><%= @label %></.link>
    """
  end
end
