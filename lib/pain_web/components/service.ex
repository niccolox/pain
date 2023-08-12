defmodule PainWeb.Components.Service do
  use Surface.LiveComponent

  prop service, :any, required: true
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
      <div class="header">
        <h4>{@service["name"]}</h4>
        {#if @service["hanyu"]}<h4>{@service["hanyu"]}</h4>{/if}
        <span>{@service["duracion"]}</span>
        <button class={["btn", "btn-active": @chosen]}>Book</button>
      </div>
      <p>{@service["descripcion"]}</p>
    </div>
    """
  end
end
