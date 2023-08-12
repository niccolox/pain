defmodule PainWeb.Components.Service do
  use Surface.LiveComponent
  alias PainWeb.Components.Accion

  prop service, :any, required: true
  prop choose, :event
  prop chosen, :boolean, default: false

  def render(assigns) do
    ~F"""
    <style>
      p { margin-bottom: 1.2rem; }
      .header {
        display: grid;
        grid-template-columns: 1fr auto;
        grid-template-rows: auto auto;
        margin-bottom: 0.6rem;
      }
      .header h4, .header span { grid-column: 1; }
      .header button { grid-row: 1 / -1; grid-column: 2; }
    </style>

    <div>
      <Accion accion="Book" click={@choose} shape={@service["name"]}>
        <h4>{@service["name"]}</h4>
        {#if @service["hanyu"]}<h4>{@service["hanyu"]}</h4>{/if}
        <span>{@service["duracion"]}</span>
      </Accion>

      <p>{@service["descripcion"]}</p>
    </div>
    """
  end
end
