defmodule PainWeb.Components.CardExamples do
  @moduledoc """
  Example using the `rounded` property and slots.
  """

  use Surface.Catalogue.Examples,
    subject: PainWeb.Components.Card

  alias PainWeb.Components.Card

  @example [
    title: "rounded",
    height: "315px",
    assert: ["The header", "user-interfaces"]
  ]

  @doc "An example of a rounded card."
  def rounded_card_example(assigns) do
    ~F"""
    <Card rounded>
      <:header>
        The header
      </:header>

      Start building rich interactive user-interfaces,
      writing minimal custom Javascript. Built on top
      of Phoenix LiveView, Surface leverages the amazing
      Phoenix Framework to provide a fast and productive
      solution to build modern web applications.
    </Card>
    """
  end

  @example [
    title: "footer",
    height: "360px",
    assert: ["The header", "user-interfaces", "#surface", "#phoenix", "#tailwindcss"]
  ]

  @doc "An example of a card with footer."
  def card_with_footer_example(assigns) do
    ~F"""
    <Card>
      <:header>
        The header
      </:header>

      Start building rich interactive user-interfaces,
      writing minimal custom Javascript. Built on top
      of Phoenix LiveView, Surface leverages the amazing
      Phoenix Framework to provide a fast and productive
      solution to build modern web applications.

      <:footer>
        <span>#surface</span>
        <span>#phoenix</span>
        <span>#tailwindcss</span>
      </:footer>
    </Card>
    """
  end
end
