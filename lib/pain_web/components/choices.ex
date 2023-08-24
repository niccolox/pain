defmodule PainWeb.Components.Choices do
  use Surface.Component

  prop number, :integer
  prop choices, :map
  prop accion, :event
  prop name, :string
  prop class, :css_class
  prop enabled, :map, default: %{}

  slot default
  slot summary

  def render(assigns) do
    ~F"""
    <style>
      .choices {
        margin: 1rem 0;
        display: flex;
        flex-direction: column;
      }
      .opcion, .summary {
        width: 100%;
        display: flex;
        justify-content: space-between;
        align-items: start;
      }
      .summary { padding-top: 0.5rem; }
      @media (max-width: 1080px) { .summary { display: block; } }
    </style>

    <section class="choices" >
      <div class="opcion">
        <#slot/>
        <span class="join">{#for num <- (1..@number)}
          <button phx-value-num={num} phx-value-name={@name}
            :on-click={if @enabled[num] == false, do: nil, else: @accion}
          class={"btn", "join-item",
            "btn-active": @choices[num] == @name,
            "btn-disabled": @enabled[num] == false,
          } >
            {if @choices[num] == @name, do: "✔", else: "🗙"}
          </button>
        {/for}</span>
      </div>
      <div class="summary"><#slot {@summary} /></div>
    </section>
    """
  end
end
