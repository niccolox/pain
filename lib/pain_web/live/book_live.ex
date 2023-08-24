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

  def handle_event("employ", params, socket) do
    {:noreply, update(socket, :employed, fn employed ->
      Map.update(employed, String.to_integer(params["num"]), params["name"],
        &(if &1 == params["name"], do: nil, else: params["name"]))
    end)}
  end
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

  def all_employees do
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

  def scheduled_block(schedule) do
    (schedule <> ":00Z-04:00")
    |> String.slice(0, 20)
    |> NaiveDateTime.from_iso8601()
    |> elem(1)
  end

  def employee_keys, do: all_employees() |> Enum.map(&(&1["schedule_key"]))

  def schedule_calendars(schedule, assigns) do
    (schedule <> Pain.Schedule.ending)
    |> check_blocks_on_calendars(assigns[:services] |> service_keys, employee_keys())
  end

  def employee_bookable?(calendars, employee, services, employed) do
    ss = all_services()
    case (employed |> Enum.find(fn {_, name} -> name == employee["name"] end)) do
      # remember: you can only book an employee once per block.
      {n, _employee} ->
        Map.put %{ 1 => false, 2 => false, 3 => false, 4 => false }, n, true
      # usually, check each employee's schedule.
      _ ->
        services |> Enum.reduce(%{}, fn { n, s }, map ->
          service = (ss |> Enum.filter(&(&1["name"] == s)) |> hd)["schedule_key"]
          Map.put(map, n, calendars |> employee_can_do?(employee, service))
        end)
    end
  end

  @doc """
  PainWeb.BookLive.bookable_by_gender(cals, %{
  1 => "90Min Reflexology with Chinese Medicine",
  2 => "90min Massage",
  3 => "Cupping",
  4 => "Wet Cupping" },
  %{ 1 => "Bin Wang"})
  """
  def bookable_by_gender(calendars, services, employed) do
    calendars
    |> bookable_employees_by_service(services)
    |> Enum.reduce(%{}, fn {n, employees}, remaining ->
      Map.put(remaining, n, employees
      |> Enum.filter(&(!Enum.member?(Map.values(employed), &1["name"]))))
    end)
    |> Enum.reduce(%{}, fn {n, employees}, by_service ->
      Map.put(by_service, n, employees |> Enum.reduce(%{}, fn employee, by_gender ->
        Map.update(by_gender, employee["gender"], 1, &(&1+1))
      end))
    end)
  end

  def bookable_any(calendars, services, employed, decide) do
    calendars
    |> bookable_by_gender(services, employed)
    |> Enum.reduce(%{}, fn {n, g}, by_service ->
      Map.put(by_service, n, decide.(Map.values(g) |> Enum.reduce(0, &(&1 + &2)))) end)
    |> IO.inspect
  end

  def bookable_as_gender(calendars, services, employed, gender, decide) do
    calendars
    |> bookable_by_gender(services, employed)
    |> Enum.reduce(%{}, fn {n, g}, by_service ->
      Map.put(by_service, n, decide.(g[gender] || 0)) end)
    |> IO.inspect
  end

  @doc """
  PainWeb.BookLive.bookable_employees_by_service(cals, %{
  1 => "90Min Reflexology with Chinese Medicine",
  2 => "90min Massage",
  3 => "Cupping",
  4 => "Wet Cupping" })
  """
  def bookable_employees_by_service calendars, services do
    ss = all_services()
    es = all_employees()

    services |> Enum.reduce(%{}, fn { n, s }, by_service ->
      service_key = (ss |> Enum.filter(&(&1["name"] == s)) |> hd)["schedule_key"]
      Map.put(by_service, n, es
      |> Enum.filter(fn employee -> calendars |> employee_can_do?(employee, service_key) end)
      |> Enum.map(&(Map.take(&1, ~w[name gender])))
      ) end) |> IO.inspect
  end

  def employee_can_do?(calendars, employee, service_key) do
    (calendars
    |> Enum.filter(&(&1["calendarID"] == employee["schedule_key"]))
    |> Enum.filter(&(&1["appointmentTypeID"] == service_key))
    |> Enum.filter(&(&1["valid"]))
    |> length()
    ) > 0
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
          {"Book #{ngettext("an appointment", "appointments", @number)}"}
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
          <Accion accion="Change" click="clear_services">
            <h2>You are booking:</h2>
          </Accion>

          <ul>{#for service <- chosen_services(assigns)}
            <li>
              {service["name"]}
              {#if service["hanyu"]} / {service["hanyu"]}{/if}
              {service["duracion"]}
            </li>
          {/for}</ul>

          <hr/>

          {#if !@schedule}
          <Schedule id="schedule" schedule="schedule"
            {=employee_keys()} service_keys={service_keys(@services)} />
          {#else}
            <Accion accion="Change" click="clear_schedule" shape="">
              <h2>Your {ngettext("appointment is", "appointments are", @number)} going to be:</h2>
            </Accion>

            <ul>
              <li>on {scheduled_block(@schedule) |> Calendar.strftime("%A, %m/%d, %Y")}</li>
              <li>at {scheduled_block(@schedule) |> Calendar.strftime("%H:%M (%I:%M %P)")}</li>
            </ul>

            <hr/>

            {#if map_size(@employed) < @number}
              <Accion accion={if @display_bios, do: "Hide bio", else: "Display bio"}
                click="render_bios" shape={!@display_bios}>
                <h2>Please choose {@number} {ngettext("therapist", "therapists", @number)}:</h2>
              </Accion>

              <ServiceMap {=@services} />

              <Choices {=@number} choices={@employed} accion="employ" name="_any"
                labels={@calendars |> bookable_any(@services, @employed, &(&1))}
                enabled={@calendars |> bookable_any(@services, @employed, &(&1 > 0))}
              ><span class="employ-generic">No preference</span></Choices>

              <Choices {=@number} choices={@employed} accion="employ" name="_masc"
                labels={@calendars |> bookable_as_gender(@services, @employed, "masculine", &(&1))}
                enabled={@calendars |> bookable_as_gender(@services, @employed, "masculine", &(&1 > 0))}
              ><span class="employ-generic">Any - masculine</span></Choices>

              <Choices {=@number} choices={@employed} accion="employ" name="_fem"
                labels={@calendars |> bookable_as_gender(@services, @employed, "feminine", &(&1))}
                enabled={@calendars |> bookable_as_gender(@services, @employed, "feminine", &(&1 > 0))}
              ><span class="employ-generic">Any - feminine</span></Choices>

              {#for employee <- all_employees()}
              <Employee {=employee} id={employee["name"]} {=@display_bios}
                employ="employ" choices={@employed} {=@number}
                bookable={@calendars |> employee_bookable?(employee, @services, @employed)}
              />
              {#else}<p>Seems like an error has occurred.</p>{/for}
            {#else}
              <Accion accion="Change" click="clear_employees" shape="">
                <h2>Your therapist {ngettext("choice is", "choices are", @number)}:</h2>
              </Accion>

              <ul>{#for employee <- Map.values(@employed)}
                <li>{#case employee}
                {#match "_any"}No preference
                {#match "_masc"}Any (masculine)
                {#match "_fem"}Any (feminine)
                {#match name}{name}
                {/case}</li>
              {/for}</ul>

              <hr/>

              <Accion click="book" key="book"
                accion={"Book your #{ngettext("appointment", "appointments", @number)}"} >
                <h2>Please proceed once you're ready.</h2>
              </Accion>
            {/if}
          {/if}
        {/if}
      </Card>
    </div>
    """
  end
end
