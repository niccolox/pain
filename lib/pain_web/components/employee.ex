defmodule PainWeb.Components.Employee do
  use Surface.LiveComponent
  alias PainWeb.Components.Choices

  prop employee, :any, required: true
  prop employ, :event, required: true
  prop employed, :boolean, default: false
  prop choices, :map, default: %{}

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
      section { grid-column: 2; }
      section img { grid-column: 1; grid-row: 1 / -1; }
    </style>

    <Choices {=@number} {=@choices} accion={@employ} name={@employee["name"]}>
      <img src={@employee["image"]} />
      <h2>{@employee["name"]}</h2>
      <p>{@employee["biography"]}</p>
    </Choices>
    """
  end
end
