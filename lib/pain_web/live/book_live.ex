defmodule PainWeb.BookLive do
  use Surface.LiveView
  import PainWeb.Gettext

  alias PainWeb.Components.Card
  alias PainWeb.Components.Class
  alias PainWeb.Components.Employee
  alias PainWeb.Components.Accion
  alias PainWeb.Components.Choices
  alias PainWeb.Components.Schedule

  data number, :integer, default: 1
  data services, :map, default: %{}
  data employed, :map, default: %{}
  data open_class, :string, default: ""
  data schedule_day, :string, default: Pain.Schedule.today() |> Date.to_string
  data schedule_block, :string, default: nil

  def handle_event("number", params, socket),
    do: {:noreply, assign(socket, :number, String.to_integer params["num"])}

  def handle_event("choose_service", params, socket),
    do: {:noreply, update(socket, :services,
    &(Map.put(&1, String.to_integer(params["num"]), params["name"])))}
  def handle_event("clear_services", _, socket),
    do: {:noreply, assign(socket, :services, %{})}

  def handle_event("employ", params, socket),
    do: {:noreply, update(socket, :employed,
    &(Map.put(&1, String.to_integer(params["num"]), params["name"])))}
  def handle_event("clear_employees", _, socket),
    do: {:noreply, assign(socket, :employed, %{})}

  def handle_event("open_class", params, socket),
    do: {:noreply, assign(socket, :open_class, params["name"])}

  def handle_event("schedule_day", params, socket),
    do: {:noreply, assign(socket, :schedule_day, params["day"])}

  def classed_services do
    {:ok, s} = (
      :pain
      |> Application.app_dir("priv")
      |> Path.join("services.yml")
      |> YamlElixir.read_from_file
    ); s
  end

  def all_services do
    classed_services()["classes"] |> Enum.map(fn c ->
      c["services"] |> Enum.map(&(Map.put(&1, "class", c["name"])))
    end) |> List.flatten
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
    classed_services()["classes"]
    |> Enum.map(fn class ->
      Enum.map(class["services"],
        &(if &1["hanyu"], do: &1, else: Map.put(&1, "hanyu", class["hanyu"])))
      |> Enum.filter(&(assigns[:services] |> Map.values() |> Enum.member?(&1["name"])))
    end)
    |> List.flatten
  end

  def service_keys(assigns) do
    services = all_services()
    assigns[:services] |> Map.values() |> Enum.map(fn name ->
      Enum.find(services, &(&1["name"] == name))["schedule_key"]
    end)
  end

  def render(assigns) do
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
        {#if map_size(@services) < @number}
          <p>How can we help you?</p>

          <section class="join join-vertical">
            {#for class <- classed_services()["classes"]}
            <Class {=class} id={class["name"]} choose="choose_service" chosen={@services} {=@number}
              is_open={@open_class == class["name"]} open="open_class" />
            {#else}<p>Seems like an error has occurred.</p>{/for}
          </section>
        {#else}
          <p>You are booking:</p>

          <Accion accion="Change" click="clear_services">
            <ul>{#for service <- chosen_services(assigns)}
              <li>
                {service["name"]}
                {#if service["hanyu"]} / {service["hanyu"]}{/if}
                {service["duracion"]}
              </li>
            {/for}</ul>
          </Accion>

          <hr/>

          {#if !@schedule_day || !@schedule_block}
          <Schedule id="schedule" keys={service_keys(assigns)}
            day={@schedule_day} block={@schedule_block} />
          {#else}
            {#if map_size(@employed) < @number}
              <p>Please choose {@number} {ngettext("therapist", "therapists", @number)}:</p>

              <Choices {=@number} choices={@employed} accion="employ" name="_any"
              >No preference</Choices>
              <Choices {=@number} choices={@employed} accion="employ" name="_male"
              >Any male</Choices>
              <Choices {=@number} choices={@employed} accion="employ" name="_female"
              >Any female</Choices>

              <hr/>

              {#for employee <- employees()}
                <Employee {=employee} id={employee["name"]} employ="employ" choices={@employed} {=@number} />
              {#else}<p>Seems like an error has occurred.</p>{/for}
            {#else}
              <Accion accion="Change" click="clear_employees" shape="">
                <p>Your therapist {ngettext("choice is", "choices are", @number)}:</p>
                <ul>{#for employee <- Map.values(@employed)}
                  <li>{#case employee}
                  {#match "_any"}No preference
                  {#match "_male"}Any male
                  {#match "_female"}Any female
                  {#match name}{name}
                  {/case}</li>
                {/for}</ul>
              </Accion>
            {/if}
          {/if}
        {/if}
      </Card>
    </div>
    """
  end
end
