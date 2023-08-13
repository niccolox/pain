defmodule PainWeb.Components.Employee do
  use Surface.LiveComponent
  alias PainWeb.Components.Accion

  prop employee, :any, required: true
  prop employ, :event, required: true
  prop employed, :boolean, default: false

  def render(assigns) do
    ~F"""
    <style>
      section {
        margin: 2rem 0 2rem;
        display: grid;
        grid-template-columns: 12rem auto;
        grid-template-rows: auto auto;
        grid-gap: 1rem;
      }
      section > * { grid-column: 2; }
      section img { grid-column: 1; grid-row: 1 / -1; }
    </style>

    <section>
      <img src={@employee["image"]} />
      <Accion accion={if @employed, do: "Chosen", else: "Choose"}
        click={@employ} shape={@employee["name"]} clicked={@employed}
      >
        <h2>{@employee["name"]}</h2>
      </Accion>
      <p>{@employee["biography"]}</p>
    </section>
    """
  end
end
