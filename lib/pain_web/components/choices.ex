defmodule PainWeb.Components.Choices do
  use Surface.Component

  prop number, :integer
  prop choices, :map
  prop accion, :event
  prop name, :string
  prop class, :css_class
  prop enabled, :map, default: %{}
  prop labels, :map, default: %{}

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
      button { position: relative; }
      button .label { position: absolute; bottom: 0; right: 0; }
    </style>

    <section class="choices" >
      <div class="opcion">
        <#slot/>
        <div class="join join-horizontal">
          {#for num <- (1..@number)}
          <button phx-value-num={num} phx-value-name={@name}
            :on-click={if @enabled[num] == false, do: nil, else: @accion}
            class={"btn", "join-item", "btn-active": @choices[num] == @name,
            "btn-disabled": @choices |> Map.keys |> Enum.member?(num) && @choices[num] != @name }
            disabled={@enabled[num] == false}
          >
            {if @choices[num] == @name, do: yes(assigns), else: no(assigns)}
            {#if @labels[num]}<span class="label">{@labels[num]}</span>{/if}
          </button>
          {/for}
        </div>
      </div>
      <div class="summary"><#slot {@summary} /></div>
    </section>
    """
  end

  def no(assigns) do
  ~F"""
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 32 32"><path fill="currentColor" d="M24 9.4L22.6 8L16 14.6L9.4 8L8 9.4l6.6 6.6L8 22.6L9.4 24l6.6-6.6l6.6 6.6l1.4-1.4l-6.6-6.6L24 9.4z"/></svg>
  """
  end

  def yes(assigns) do
  ~F"""
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 32 32"><path fill="currentColor" d="m13 24l-9-9l1.414-1.414L13 21.171L26.586 7.586L28 9L13 24z"/></svg>
  """
  end
end
