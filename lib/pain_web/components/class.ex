defmodule PainWeb.Components.Class do
  use Surface.LiveComponent
  alias PainWeb.Components.Service

  prop class, :any, required: true
  prop choose, :event
  prop chosen, :map
  prop number, :integer
  prop open, :event
  prop is_open, :boolean, default: false

  # <Class {=class} id={class["name"]} choose="choose" choices={@services} {=@number} />
  def render(assigns) do
    ~F"""
    <style>
      .collapse { @apply border-2; }
      p { margin-bottom: 1rem; }
    </style>

    <div :on-click={@open} phx-value-name={@class["name"]}
    class={"collapse", "collapse-arrow", "join-item", "border-neutral", "collapse-open": @is_open } >
      <input type="radio" name="my-accordion-1" />
      <div class="collapse-title text-xl font-medium">
        <h3>{@class["name"]}</h3>
        {#if @class["hanyu"]}<h3>{@class["hanyu"]}</h3>{/if}
      </div>

      <div class="collapse-content">
        <p>{@class["descripcion"]}</p>

        {#for service <- @class["services"]}
          <Service id={service["name"]} {=service} {=@chosen} {=@choose} {=@number} />
        {#else}<p>Seems like an error has occurred.</p>{/for}
      </div>
    </div>
    """
  end
end
