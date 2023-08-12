defmodule PainWeb.Components.Service do
  use Surface.LiveComponent

  prop service, :any, required: true

  def render(assigns) do
    ~F"""
    <style>
      p { margin-bottom: 1rem; }
    </style>

    <div>
      <h4>{@service["name"]}</h4>
      <span>{@service["duracion"]}</span>
      <p>{@service["descripcion"]}</p>
    </div>
    """
  end
end
