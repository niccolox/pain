defmodule PainWeb.BookLive do
  use Surface.LiveView
  alias PainWeb.Components.Card

  data number, :integer, default: 1

  def handle_event("number", params, socket) do
    {:noreply, assign(socket, :number, String.to_integer params["num"])}
  end

  def render(assigns) do
    {:ok, services } = (
      :pain
      |> Application.app_dir("priv")
      |> Path.join("services.yml")
      |> YamlElixir.read_from_file
    )

    ~F"""
    <style>
      section { margin: 1rem 0 1rem; }
      section p { margin-bottom: 1rem; }
      #number-people { display: flex; flex-direction: column; }
      #number-people .join { align-self: center; }
      #class .join-item { @apply border-2; }
    </style>

    <div class="flex justify-center mt-12">
      <Card max_width="lg" rounded>
        <:header>
          Book an appointment
        </:header>

        <section id="number-people">
          <p>How many people are you booking for?</p>
          <div class="join">
            <button class={["btn", "join-item", (@number == 1) && "btn-active"]}
              phx-value-num={1} :on-click="number" >Only me</button>
            <button class={["btn", "join-item", (@number == 2) && "btn-active"]}
              phx-value-num={2} :on-click="number" >+1</button>
            <button class={["btn", "join-item", (@number == 3) && "btn-active"]}
              phx-value-num={3} :on-click="number" >+2</button>
            <button class={["btn", "join-item", (@number == 4) && "btn-active"]}
              phx-value-num={4} :on-click="number" >+3</button>
          </div>
        </section>

        <section id="class" class="join join-vertical">
          <p>Please choose a category:</p>

          {#for class <- services["classes"]}
            <div class="collapse collapse-arrow join-item border-neutral">
              <input type="radio" name="my-accordion-1" />
              <div class="collapse-title text-xl font-medium">
                <h3>{class["name"]}</h3>
              </div>

              <div class="collapse-content">
                <p>{class["descripcion"]}</p>

                {#for service <- class["services"]}
                  <h4>{service["name"]}</h4>
                  <span>{service["duracion"]}</span>
                  <p>{service["descripcion"]}</p>
                {#else}<p>Seems like an error has occurred.</p>{/for}
              </div>
            </div>

          {#else}<p>Seems like an error has occurred.</p>{/for}
        </section>
      </Card>
    </div>
    """
  end
end
