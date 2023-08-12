defmodule PainWeb.Components.Class do
  use Surface.LiveComponent
  alias PainWeb.Components.Service

  prop class, :any, required: true

  def render(assigns) do
    ~F"""
    <style>
      .collapse { @apply border-2; }
      p { margin-bottom: 1rem; }
    </style>

    <div class="collapse collapse-arrow join-item border-neutral">
      <input type="radio" name="my-accordion-1" />
      <div class="collapse-title text-xl font-medium">
        <h3>{@class["name"]}</h3>
        {#if @class["hanyu"]}<h3>{@class["hanyu"]}</h3>{/if}
      </div>

      <div class="collapse-content">
        <p>{@class["descripcion"]}</p>

        {#for service <- @class["services"]}
          <Service id={service["name"]} service={service} />
        {#else}<p>Seems like an error has occurred.</p>{/for}
      </div>
    </div>
    """
  end
end
