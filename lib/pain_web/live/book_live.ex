defmodule PainWeb.BookLive do
  use Surface.LiveView
  alias PainWeb.Components.Card
  alias PainWeb.Components.Class
  alias PainWeb.Components.Accion

  data number, :integer, default: 1
  data chosen, :any, default: ""

  def handle_event("number", params, socket) do
    {:noreply, assign(socket, :number, String.to_integer params["num"])}
  end

  def handle_event("choose", params, socket) do
    {:noreply, assign(socket, :chosen, params["shape"])}
  end

  def services do
    {:ok, s} = (
      :pain
      |> Application.app_dir("priv")
      |> Path.join("services.yml")
      |> YamlElixir.read_from_file
    ); s
  end

  def chosen_services(assigns) do
    services()["classes"]
    |> Enum.map(fn class ->
      Enum.map(class["services"], &(
        if &1["hanyu"], do: &1, else: Map.put(&1, "hanyu", class["hanyu"])
      )) |> Enum.filter(
        &(&1["name"] == assigns[:chosen])
      )
    end)
    |> List.flatten
  end

  def render(assigns) do
    chosen_service = case chosen_services(assigns) do
      [s|_] -> s
      _ -> nil
    end

    ~F"""
    <style>
      section { margin: 1rem 0 1rem; }
      section p { margin-bottom: 1rem; }
      #number-people { display: flex; flex-direction: column; }
      #number-people .join { align-self: center; }
      .order {
        display: flex;
        flex-direction: column;
      }
    </style>

    <div class="order">
      <Card max_width="lg" rounded>
        <:header>
          Book an appointment
        </:header>

        <p>How many people are you booking for?</p>

        <section id="number-people">
          <div class="join">
            <button class={["btn", "join-item", "btn-active": @number == 1]}
              phx-value-num={1} :on-click="number" >Only me</button>
            <button class={["btn", "join-item", "btn-active": @number == 2]}
              phx-value-num={2} :on-click="number" >+1</button>
            <button class={["btn", "join-item", "btn-active": @number == 3]}
              phx-value-num={3} :on-click="number" >+2</button>
            <button class={["btn", "join-item", "btn-active": @number == 4]}
              phx-value-num={4} :on-click="number" >+3</button>
          </div>
        </section>

        {#if !chosen_service}
          <p>Please choose a category:</p>

          <section class="join join-vertical">
            {#for class <- services()["classes"]}
              <Class class={class} id={class["name"]} choose="choose" {=@chosen} />
            {#else}<p>Seems like an error has occurred.</p>{/for}
          </section>
        {#else}
          <p>You chose:</p>

          <section>
            <Accion accion="Change" click="choose" shape="">
              <h2>
                {chosen_service["name"]}
                {#if chosen_service["hanyu"]} / {chosen_service["hanyu"]}{/if}
              </h2>
              {chosen_service["duracion"]}
            </Accion>
          </section>
        {/if}
      </Card>
    </div>
    """
  end
end
