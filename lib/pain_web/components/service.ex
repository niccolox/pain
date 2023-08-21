defmodule PainWeb.Components.Service do
  use Surface.LiveComponent
  alias PainWeb.Components.Choices

  prop service, :any, required: true
  prop choose, :event
  prop chosen, :map
  prop number, :integer, default: 1

  # <Service id={service["name"]} {=service} {=@chosen} {=@choose} {=@number} />
  def render(assigns) do
    ~F"""
    <style>
      div { display: flex; flex-direction: column; }
      span { display: block; margin-bottom: 0.5rem; }
    </style>

    <Choices accion={@choose} name={@service["name"]} {=@number} choices={@chosen}>
      <div>
        <h4>{@service["name"]}</h4>
        {#if @service["hanyu"]}<h4>{@service["hanyu"]}</h4>{/if}
      </div>
      <:summary>
        <span>{@service["duracion"]}</span>
        {@service["descripcion"]}
        </:summary>
    </Choices>
    """
  end
end
