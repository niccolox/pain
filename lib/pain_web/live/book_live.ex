defmodule PainWeb.BookLive do
  use Surface.LiveView
  import PainWeb.Gettext

  alias PainWeb.Components.Card
  alias PainWeb.Components.Class
  alias PainWeb.Components.Employee
  alias PainWeb.Components.Accion

  data number, :integer, default: 1
  data chosen, :any, default: ""
  data employed, :list, default: []

  def handle_event("number", params, socket) do
    {:noreply, assign(socket, :number, String.to_integer params["num"])}
  end

  def handle_event("choose", params, socket) do
    {:noreply, assign(socket, :chosen, params["shape"])}
  end

  def handle_event("employ", params, socket) do
    {:noreply, update(socket, :employed, &(&1 ++ [params["shape"]]))}
  end
  def handle_event("unemploy", _, socket), do: {:noreply, assign(socket, :employed, [])}

  def services do
    {:ok, s} = (
      :pain
      |> Application.app_dir("priv")
      |> Path.join("services.yml")
      |> YamlElixir.read_from_file
    ); s
  end

  def employees do
    {:ok, e} = (
      :pain
      |> Application.app_dir("priv")
      |> Path.join("employees.yml")
      |> YamlElixir.read_from_file
    ); e["employees"]
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

    employees_chosen = (
      if Enum.member?(assigns[:employed], "_random"), do: true,
      else: length(assigns[:employed]) == assigns[:number]
    )

    ~F"""
    <style>
      section { margin: 1rem 0 1rem; }
      section p { margin-bottom: 1rem; }
      #number-people { display: flex; flex-direction: column; }
      #number-people .join { align-self: center; }
      .order {
        display: flex;
        justify-content: center;
        position: absolute;
        top: 4rem;
        width: 100vw;
      }
      hr { margin: 2rem 0 2rem; }
      ul { padding-left: 1rem; list-style: disc; }
    </style>

    <div class="order">
      <Card rounded>
        <:header>
          Book an appointment
        </:header>

        <p>How many people are you booking for?</p>

        <section id="number-people">
          <div class="join">
            <button class={"btn", "join-item", "btn-active": @number == 1}
              phx-value-num={1} :on-click="number" >Only me</button>
            <button class={"btn", "join-item", "btn-active": @number == 2}
              phx-value-num={2} :on-click="number" >+1</button>
            <button class={"btn", "join-item", "btn-active": @number == 3}
              phx-value-num={3} :on-click="number" >+2</button>
            <button class={"btn", "join-item", "btn-active": @number == 4}
              phx-value-num={4} :on-click="number" >+3</button>
          </div>
        </section>

        <hr/>
        {#if !chosen_service}
          <p>Please choose a category:</p>

          <section class="join join-vertical">
            {#for class <- services()["classes"]}
              <Class class={class} id={class["name"]} choose="choose" {=@chosen} />
            {#else}<p>Seems like an error has occurred.</p>{/for}
          </section>
        {#else}
          <p>You are booking:</p>

          <section>
            <Accion accion="Change" click="choose" shape="">
              <h2>
                {chosen_service["name"]}
                {#if chosen_service["hanyu"]} / {chosen_service["hanyu"]}{/if}
              </h2>
              {chosen_service["duracion"]}
            </Accion>
          </section>

          <hr/>
          {#if !employees_chosen}
            <Accion accion="Assign randomly" click="employ" shape="_random">
              <p>Please choose {@number} {ngettext("therapist", "therapists", @number)}:</p>
            </Accion>

            {#for employee <- employees()}
              <Employee {=employee} id={employee["name"]} employ="employ"
                employed={Enum.member?(@employed, employee["name"])} />
            {#else}<p>Seems like an error has occurred.</p>{/for}
          {#else}
            <Accion accion="Change" click="unemploy" shape="">
              <p>Your {ngettext("therapist is", "therapists are", @number)}:</p>
              <ul>{#for employee <- @employed}
                <li>{if employee == "_random", do: "Randomly assigned", else: employee}</li>
              {/for}</ul>
            </Accion>
          {/if}
        {/if}
      </Card>
    </div>
    """
  end
end
