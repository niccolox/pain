defmodule PainWeb.Components.Accion do
  use Surface.Component

  prop accion, :string
  prop click, :event
  prop shape, :string
  prop clicked, :boolean, default: false

  slot default

  def render(assigns) do
    ~F"""
    <style>
      p { margin-bottom: 1.2rem; }
      .accion {
        display: flex;
        flex-direction: row;
        justify-content: space-between;
        align-content: center;
        margin-bottom: 0.6rem;
        align-items: center;
      }
      .accion .main { grid-column: 1; }
      .accion button { grid-row: 1 / -1; grid-column: 2; }
    </style>

    <div class="accion">
      <div class="main">
        <#slot/>
      </div>

      <button class={"btn", "btn-active": @clicked} :on-click={@click} phx-value-shape={@shape}>
        {@accion}
      </button>
    </div>
    """
  end
end
