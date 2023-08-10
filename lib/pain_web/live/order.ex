defmodule PainWeb.Order do
  use PainWeb, :surface_live_view

  alias SurfaceBulma.Button
  alias SurfaceBulma.Card
  alias SurfaceBulma.Title

  def render(assigns) do
    ~F"""
    <Card>
      <:header>
      <Title size="3" class="">Schedule an appointment</Title>
      </:header>

      <Button>asdf</Button>
      <Button>asdf</Button>
      <Button>asdf</Button>

      <p>
        Start building rich interactive user-interfaces, writing minimal custom Javascript.
        Built on top of Phoenix LiveView, <strong>Surface</strong> leverages the amazing
        <strong>Phoenix Framework</strong> to provide a fast and productive solution to
        build modern web applications.
      </p>

      <:footer>
        <span class="tag">#surface</span>
        <span class="tag">#phoenix</span>
        <span class="tag">#tailwindcss</span>
      </:footer>
    </Card>
    """
  end
end
