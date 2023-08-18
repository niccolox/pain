defmodule PainWeb.Components.Choices do
  use Surface.Component

  prop number, :integer
  prop choices, :map
  prop accion, :event
  prop name, :string
  prop class, :css_class

  slot default

  def render(assigns) do
    ~F"""
    <style>
      section { padding: 0.5rem 0; }
      .join { float: right; }
    </style>

    <section {=@class} >
      <#slot/>
      <span class="join">{#for num <- (1..@number)}
        <button phx-value-num={num} phx-value-name={@name} :on-click={@accion}
        class={"btn", "join-item", "btn-active": @choices[num] == @name} >
          {if @choices[num] == @name, do: "✔", else: "🗙"}
        </button>
      {/for}</span>
    </section>
    """
  end
end
