defmodule PainWeb.BookLive do
  use Surface.LiveView
  import PainWeb.Gettext

  import Pain.Schedule, only: [check_blocks_on_calendars: 3]

  alias PainWeb.Components.Card
  alias PainWeb.Components.Class
  alias PainWeb.Components.Employee
  alias PainWeb.Components.Accion
  alias PainWeb.Components.Choices
  alias PainWeb.Components.Schedule
  alias PainWeb.Components.ServiceMap

  data number, :integer, default: 1
  data open_class, :string, default: ""
  data services, :map, default: %{}
  data employed, :map, default: %{}
  data schedule, :string, default: nil
  data calendars, :map, default: %{}
  data display_bios, :boolean, default: true

  def handle_event("number", params, socket),
    do: {:noreply, assign(socket, :number, String.to_integer params["num"])}

  def handle_event("open_class", params, socket),
    do: {:noreply, assign(socket, :open_class, params["name"])}

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

  def handle_event("clear_schedule", _, socket),
    do: {:noreply, assign(socket, :schedule, nil)}
  def handle_event("schedule", params, socket) do
    {:noreply, socket
    |> assign(:schedule, params["shape"])
    |> assign(:calendars, params["shape"] |> schedule_calendars(socket.assigns))
    }
  end

  def handle_event("render_bios", params, socket), do:
    {:noreply, socket |> assign(:display_bios, params["shape"]) }

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

  def service_keys(services) do
    all = all_services()
    services |> Map.values() |> Enum.map(fn name ->
      Enum.find(all, &(&1["name"] == name))["schedule_key"]
    end)
  end

  def scheduled_block(schedule),
    do: NaiveDateTime.from_iso8601(schedule |> String.slice(0, 20)) |> elem(1)

  def employee_keys do
    employees() |> Enum.map(&(&1["schedule_key"]))
  end

  def schedule_calendars(schedule, assigns) do
    schedule
    |> check_blocks_on_calendars(
      assigns[:services] |> service_keys(),
      employee_keys())
  end

  def render(assigns) do
    ~F"""
    <style>
      section { margin: 1rem 0 1rem; }
      h2 { font-weight: 600; }
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
      hr { margin: 0 0 2rem; }
      ul { margin-top: 1rem; margin-bottom: 1rem; padding-left: 1rem; list-style: disc; }
      .employ-generic { align-self: center; }
    </style>

    <div class="order">
      <Card rounded>
        <:header>
          Book an appointment
        </:header>

        <h2>How many people are you booking for?</h2>

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
          <h2>How can we help you?</h2>

          <section class="join join-vertical">
            {#for class <- classed_services()["classes"]}
            <Class {=class} id={class["name"]} choose="choose_service" chosen={@services} {=@number}
              is_open={@open_class == class["name"]} open="open_class" />
            {#else}<p>Seems like an error has occurred.</p>{/for}
          </section>
        {#else}
          <h2>You are booking:</h2>

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

          {#if !@schedule}
          <Schedule id="schedule" schedule="schedule"
            {=employee_keys()} service_keys={service_keys(@services)} />
          {#else}
            <Accion accion="Change" click="clear_schedule" shape="">
            <h2>Your appointment is going to be:</h2>
              <ul>
              <li>on {scheduled_block(@schedule) |> Calendar.strftime("%A, %m/%d, %Y")}</li>
              <li>at {scheduled_block(@schedule) |> Calendar.strftime("%H:%M (%I:%M %P)")}</li>
              </ul>
            </Accion>
            <hr/>

            {#if map_size(@employed) < @number}
              <Accion accion={if @display_bios, do: "Hide bio", else: "Display bio"}
                click="render_bios" shape={!@display_bios}>
                <h2>Please choose {@number} {ngettext("therapist", "therapists", @number)}:</h2>
              </Accion>

              <ServiceMap {=@services} />

              <Choices {=@number} choices={@employed} accion="employ" name="_any"
              ><span class="employ-generic">No preference</span></Choices>
              <Choices {=@number} choices={@employed} accion="employ" name="_masc"
              ><span class="employ-generic">Any (masculine)</span></Choices>
              <Choices {=@number} choices={@employed} accion="employ" name="_fem"
              ><span class="employ-generic">Any (feminine)</span></Choices>

              {#for employee <- employees()}
              <Employee {=employee} id={employee["name"]} {=@display_bios}
                employ="employ" choices={@employed} {=@number} />
              {#else}<p>Seems like an error has occurred.</p>{/for}
            {#else}
              <Accion accion="Change" click="clear_employees" shape="">
                <p>Your therapist {ngettext("choice is", "choices are", @number)}:</p>
                <ul>{#for employee <- Map.values(@employed)}
                  <li>{#case employee}
                  {#match "_any"}No preference
                  {#match "_masc"}Any (masculine)
                  {#match "_fem"}Any (feminine)
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
