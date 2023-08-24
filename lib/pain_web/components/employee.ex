defmodule PainWeb.Components.Employee do
  use Surface.LiveComponent
  alias PainWeb.Components.Choices

  prop employee, :any, required: true
  prop employ, :event, required: true
  prop choices, :map, default: %{}
  prop number, :integer, default: 1
  prop display_bios, :boolean, default: true
  prop bookable, :map, default: %{}

  def render(assigns) do
    ~F"""
    <style>
      h2 { align-self: center; }
      img { max-width: 40%; margin-right: 1rem; }
      @media (max-width: 1080px) {
        img { float: left; }
      }
    </style>

    <Choices {=@number} {=@choices} accion={@employ}
      name={@employee["name"]} enabled={@bookable} >
      <h2>{@employee["name"]}</h2>
      <:summary>
        <img src={@employee["image"]} />
        <p>{if @display_bios, do: @employee["biography"],
          else: Squish.pare(@employee["biography"], size: 160)}
        </p>
      </:summary>
    </Choices>
    """
  end
end
