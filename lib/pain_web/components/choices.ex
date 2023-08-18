defmodule PainWeb.Components.Choices do
  use Surface.Component

  prop number, :integer
  prop choices, :map
  prop accion, :event
  prop name, :string
  prop class, :css_class

  slot default
  slot summary

  def render(assigns) do
    ~F"""
    <style>
      .choices {
        margin: 0.5rem 0;
        display: flex;
        flex-direction: column;
      }
      .opcion, .summary {
        width: 100%;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      .summary { padding-top: 0.5rem; }
      @media (max-width: 1080px) { .summary { display: block; } }
    </style>

    <section class="choices" >
      <div class="opcion">
        <#slot/>
        <span class="join">{#for num <- (1..@number)}
          <button phx-value-num={num} phx-value-name={@name} :on-click={@accion}
          class={"btn", "join-item", "btn-active": @choices[num] == @name} >
            {if @choices[num] == @name, do: "✔", else: "🗙"}
          </button>
        {/for}</span>
      </div>
      <div class="summary"><#slot {@summary} /></div>
    </section>
    """
  end
end
