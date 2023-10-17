defmodule PainWeb.BookLive do
  use Surface.LiveView
  import PainWeb.Gettext

  import Pain.Schedule, only: [check_blocks_on_calendars: 3]

  alias PainWeb.Components.Accion
  alias PainWeb.Components.BodyMap
  alias PainWeb.Components.Choices
  alias PainWeb.Components.Class
  alias PainWeb.Components.Conditions
  alias PainWeb.Components.Employee
  alias PainWeb.Components.Schedule
  alias PainWeb.Components.ServiceMap
  alias Surface.Components.Form

  import PainWeb.CoreComponents, only: [modal: 1, show_modal: 1, hide_modal: 1]

  data number, :integer, default: 1
  data open_class, :string, default: ""
  data schedule, :string, default: nil
  data display_bios, :boolean, default: true

  data services, :map, default: %{}
  data employed, :map, default: %{}
  data calendars, :map, default: %{}
  data limbs, :map, default: %{}
  data addons, :map, default: %{}
  data all_addons, :list, default: []

  data customer, :form, default:  %{
    "name" => "",
    "phone" => "",
    "email" => "",
    "reference" => "",
    "conditions" => false,
  }
  data booked, :list, default: nil

  def mount _, _, socket do
    { :ok, socket |> assign(:all_addons, Pain.Schedule.addons) }
  end

  def handle_event("bypass", _, socket) do
    {:noreply, socket |> assign(%{
      number: 4,
      services: %{
        1 => "90Min Reflexology with Chinese Medicine",
        2 => "90min Massage",
        3 => "Cupping",
        4 => "Wet Cupping"
      },
      schedule: "2023-09-30T19:00",
      employed: %{1 => "_fem", 2 => "_masc", 3 => "Andy Ji", 4 => "Bin Wang"}
    })}
  end

  def handle_event("number", params, socket),
    do: {:noreply, assign(socket, :number, String.to_integer params["num"])}
  def handle_event("open_class", params, socket),
    do: {:noreply, assign(socket, :open_class, params["name"])}

  def handle_event("choose_service", params, socket) do
    num = String.to_integer(params["num"])
    service = all_services() |> Enum.filter(& &1["name"] == params["name"]) |> hd |> IO.inspect

    {:noreply, socket
    |> update(:services, &(Map.put(&1, num, params["name"])))
    |> update(:limbs, fn limbs ->
      case service["class"] do
        "Body Massage" ->
          Map.update(limbs, num, ["_choose"], & &1 ++ ["_choose"] |> Enum.uniq)
        _ -> limbs
      end
    end)
    }
  end

  def handle_event("choose_limb", params, socket) do
    num = String.to_integer(params["num"])
    {:noreply, socket
    |> update(:limbs, fn limbs ->
      Map.update(limbs, num, [params["limb"]], &
        case Enum.member?(&1, params["limb"]) do
          false -> &1 ++ [params["limb"]] |> Enum.uniq
          true -> &1 -- [params["limb"]]
        end
      )
    end)
    }
  end

  def handle_event("begin_choosing_limbs", params, socket) do
    num = String.to_integer(params["num"])
    {:noreply, socket
    |> update(:limbs, fn limbs ->
      Map.update(limbs, num, ["_choose"], & &1 ++ ["_choose"] |> Enum.uniq)
    end)
    }
  end

  def handle_event("clear_limbs", params, socket) do
    num = String.to_integer(params["num"])
    {:noreply, socket
    |> update(:limbs, fn limbs -> Map.put(limbs, num, ["_choose"]) end)
    }
  end

  def handle_event("done_choosing_limbs", params, socket) do
    num = String.to_integer(params["num"])
    {:noreply, socket
    |> update(:limbs, fn limbs -> Map.update(limbs, num, [], & &1 -- ["_choose"]) end)
    }
  end

  def handle_event("clear_services", _, socket) do
    {:noreply, socket
    |> assign(:services, %{})
    |> assign(:limbs, %{})
    |> assign(:schedule, nil)
    |> assign(:employed, %{})
    }
  end

  def handle_event("employ", params, socket) do
    {:noreply, update(socket, :employed, fn employed ->
      Map.update(employed, String.to_integer(params["num"]), params["name"],
        &(if &1 == params["name"], do: nil, else: params["name"]))
    end)}
  end

  def handle_event("clear_employees", _, socket) do
    {:noreply, socket |> assign(:employed, %{}) }
  end

  def handle_event("clear_schedule", _, socket) do
    {:noreply, socket
    |> assign(:schedule, nil)
    |> assign(:employed, %{})
    }
  end

  def handle_event("schedule", params, socket) do
    {:noreply, socket
    |> assign(:schedule, params["shape"])
    |> assign(:calendars, params["shape"] |> schedule_calendars(socket.assigns))
    }
  end

  def handle_event("render_bios", params, socket), do:
    {:noreply, socket |> assign(:display_bios, params["shape"]) }

  def handle_event("customer", params, socket) do
    {:noreply, socket |> assign(:customer, params
    |> Map.take(~w[name phone email reference conditions])) }
  end

  def handle_event("addon", params, socket) do
    num = String.to_integer(params["num"])
    addon = String.to_integer(params["addon"])
    {:noreply, socket |> update(:addons, fn addons ->
      if Enum.member?(addons[num] || [], addon),
        do: Map.update(addons, num, [], & &1 -- [addon]),
        else: Map.update(addons, num, [addon], & &1 ++ [addon])
    end) }
  end

  def handle_event("book", _, socket) do
    links = (
      socket.assigns
      |> Map.take(~w[ employed schedule customer limbs ]a)
      |> Pain.Order.book(
        chosen_services(socket.assigns[:services]),
        socket.assigns[:addons])
    ) |> IO.inspect()
    {:noreply, socket |> assign(:booked, links) }
  end

  def handle_info {process, response}, socket do
    Process.demonitor(process, [:flush])
    send_update Schedule, id: "schedule", possible: response, process: nil
    {:noreply, socket}
  end

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

  def chosen_services(services) do
    all = classed_services()["classes"] |> Enum.map(fn class ->
      class["services"]
      |> Enum.map(&(if &1["hanyu"], do: &1, else: Map.put(&1, "hanyu", class["hanyu"])))
      |> Enum.map(&(Map.put(&1, "class", class["name"])))
    end) |> List.flatten

    services
    |> Enum.reduce(%{}, fn { n, name }, chosen ->
      Map.put(chosen, n, all |> Enum.find(&(&1["name"] == name)))
    end)
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
  end

  def bookable_as_gender(calendars, services, employed, gender, decide) do
    calendars
    |> bookable_by_gender(services, employed)
    |> Enum.reduce(%{}, fn {n, g}, by_service ->
      Map.put(by_service, n, decide.(g[gender] || 0)) end)
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
      ) end)
  end

  def employee_can_do?(calendars, employee, service_key) do
    (calendars
    |> Enum.filter(&(&1["calendarID"] == employee["schedule_key"]))
    |> Enum.filter(&(&1["appointmentTypeID"] == service_key))
    |> Enum.filter(&(&1["valid"]))
    |> length()
    ) > 0
  end

  def needing_choice(limbs) do
    limbs
    |> Enum.filter(fn {_n, limbs} -> Enum.member?(limbs, "_choose") end)
    |> Map.new
  end

  def render(assigns) do
    ~F"""
    <style>
      section { margin: 1rem 0 1rem; }
      h2 { font-weight: 600; margin-bottom: 1rem; }
      h3 { font-weight: 500; }
      section p { margin-bottom: 1rem; }
      #number-people { display: flex; flex-direction: column; }
      #number-people .join { align-self: center; }
      .order {
        display: flex;
        flex-direction: column;
        padding: 1rem;
        max-width: 60rem;
        justify-content: center;
        position: absolute;
        top: 4rem;
      }
      hr { margin: 0 0 2rem; }
      ul { margin-top: 1rem; margin-bottom: 1rem; padding-left: 1rem; list-style: disc; }
      ul.services li { margin-bottom: 1rem; }
      .employ-generic { align-self: center; }
      .bypass { max-width: 40rem; margin: auto; }
      .form {
        display: grid;
        align-items: center;
        grid-template-columns: auto auto 1fr;
        grid-gap: 1rem;
        margin-bottom: 2rem;
        text-align: right;
      }
      .field { display: contents; }
      .required :deep(label)::before { content: '*'; color: #117864; }
      .field :deep(label) { grid-column: 2; }
      .field :deep(input) { grid-column: 3; }
      a.conditions { text-decoration: underline; }

      h1 {
        @apply p-6 font-semibold text-2xl text-brand w-full
        place-content-center;
        width: auto;
      }
      .accommodation {
        font-style: italic;
        max-width: 30rem;
        border-left: 4px solid #888;
        padding-left: 8px;
      }
      .accommodation a { text-decoration: underline; }
    </style>

    {#if System.get_env("ORDER_BYPASS")}
      <div class="bypass"><Accion accion="Bypass" click="bypass">
        In a hurry? Use a pre-made order.
      </Accion></div>
    {/if}

    <div class="order">
      <h1><a href="https://painawayofphilly.com">Pain Away of Philly</a></h1>
      <h2>
        {if @booked, do: "Your order is booked.",
        else: "Book #{ngettext("an appointment", "appointments", @number)}"}
      </h2>

      {#if @booked}
        <ul>
          <li>on {scheduled_block(@schedule) |> Calendar.strftime("%A, %m/%d, %Y")}</li>
          <li>at {scheduled_block(@schedule) |> Calendar.strftime("%H:%M (%I:%M %P)")}</li>
        </ul>
        <hr/>
        {explain_services(assigns)}
      {#else}
      <h2>How many people are you booking for?</h2>

      <quote class="accommodation">
        We can accommodate a party up to 10 people at once. If you would
        like to book an appointment for 5 or more people, please call us at
        267-690-4138, or <a href="mailto:painawayphilly@gmail.com">email us</a>.
      </quote>

      <section id="number-people">
        <div class="join">
          <button class={"btn", "join-item", "btn-active": @number == 1}
            phx-value-num={1} :on-click="number" >Only me</button>
          {#for n <- [2,3,4]}
            <button class={"btn", "join-item", "btn-active": @number == n}
              phx-value-num={n} :on-click="number" >+{n-1}</button>
          {/for}
        </div>
      </section>

        {#if (map_size(@services) < @number)
        || map_size(needing_choice(@limbs)) > 0}
        <h2>How can we help you?</h2>

        <section class="join join-vertical">
          {#for class <- classed_services()["classes"]}
          <Class {=class} id={class["name"]}
            choose="choose_service" chosen={@services} {=@number}
            is_open={@open_class == class["name"]} open="open_class" />
          {#else}<p>Seems like an error has occurred.</p>{/for}
        </section>

        {#for {num, limbs} <- needing_choice(@limbs)}
          <.modal id={"choose-limb-#{num}"} show>
            <p>Customer # {num} <br/> {@services[num]}</p>
            <h2>Please choose any areas you need help on:</h2>

            <p>Once you're here, you can choose among our various massage techniques:</p>
            <ul>
              <li>Tui-Na Massage</li>
              <li>Swedish Massage</li>
              <li>Deep Tissue Massage</li>
              <li>Scalp</li>
              <li>Abdominal</li>
              <li>Lymph nodes drainage </li>
              <li>Facial </li>
            </ul>

            <button class="btn btn-primary" :on-click="done_choosing_limbs" phx-value-num={num} >
              Done
            </button>
            {#if body_areas(limbs) |> length > 0}
            <button class="btn" :on-click="clear_limbs" phx-value-num={num} >
              Clear choices
            </button>
            {/if}

            <BodyMap choose="choose_limb" number={num} chosen={@limbs[num] || []} />
          </.modal>
        {/for}

        {explain_services(assigns)}
      {#else}
        <Accion accion="Change" click="clear_services">
          <h2>You are booking:</h2>
        </Accion>
        {explain_services(assigns)}
        <hr/>

        {#if !@schedule}
          <h2>Please schedule:</h2>
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

            <h2>Nearly done; your information is needed.</h2>

            <Form for={@customer} change="customer"><div class="form">
              <Form.Field name="name" class="field required" >
                <Form.Label/>
                <Form.TextInput class="input input-bordered" value={@customer["name"]} />
              </Form.Field>

              <Form.Field name="email" class="field required">
                <Form.Label/>
                <Form.EmailInput class="input input-bordered" value={@customer["email"]} />
              </Form.Field>

              <Form.Field name="phone" class="field required">
                <Form.Label/>
                <Form.TelephoneInput class="input input-bordered" value={@customer["phone"]} />
              </Form.Field>

              <Form.Field name="reference" class="field">
                <Form.Label>How did you hear of us?</Form.Label>
                <Form.TextInput class="input input-bordered" value={@customer["reference"]} />
              </Form.Field>

              <Form.Field name="conditions" class="field required">
                <Form.Label>
                  I agree to the
                  <a href="#" class="conditions"
                    phx-click={show_modal("conditions-modal")}
                  >conditions</a>.
                </Form.Label>
                <Form.Checkbox class="toggle toggle-primary" value={@customer["conditions"]} />
              </Form.Field>
            </div></Form>

            <.modal id="conditions-modal">
              <Conditions id="conditions-render"/>
              <button class="btn btn-primary"
                    phx-click={hide_modal("conditions-modal")}
              >Done</button>
            </.modal>

            {#if (@services |> chosen_services |> map_size) > 0}
              Once your appointments have ended, you'll be charged a sum of: <br/>
              ${sum_services(chosen_services(@services)) + sum_addons(@addons, @all_addons)}
              (plus taxes)
            {/if}

            <Accion click="book" classes={["btn-primary"]}
              accion={"Book your #{ngettext("appointment", "appointments", @number)}"}
              disabled={@customer["conditions"] == "false" || @customer
              |> Map.take(~w[name phone email])
              |> Map.values() |> Enum.map(&(String.length(&1) == 0)) |> Enum.any?}
            >
              <h2>Please proceed once you're ready.</h2>
            </Accion>
          {/if}
        {/if}
      {/if}
      {/if}
    </div>
    """
  end

  def body_areas(chosen) do
    (chosen || [])
    |> Enum.filter(& !Enum.member?([nil, "_choose"], &1))
  end

  def sum_services chosen_services do
    chosen_services
    |> Enum.reduce(0, fn {_, service}, sum ->
      sum + (service["duracion"]
      |> String.split("$")
      |> Enum.at(1)
      |> String.to_float)
    end)
  end

  def sum_addons addons, all_addons do
    addons
    |> Map.values()
    |> List.flatten()
    |> Enum.map(fn key -> all_addons |> Enum.find(& &1["id"] == key) end)
    |> Enum.map(& &1["price"] |> String.to_float)
    |> Enum.sum()
  end

  def explain_services assigns do
    ~F"""
    <style>
      ul { margin-bottom: 1rem; padding-left: 1rem; list-style: disc; }
      li.service { margin-bottom: 1rem; }
      a { text-decoration: underline; }
    </style>
    <ul class="services">
    {#for {n, service} <- chosen_services(@services)}
      <li class="service">
        {service["name"]}
        {#if service["hanyu"]} / {service["hanyu"]}{/if}
        <br/>{service["duracion"]}<br/>
        {#if (@booked || []) |> Enum.at(n-1) == "/error"}
          <h3>An error occurred booking this appointment.</h3>
        {#elseif (@booked || []) |> Enum.at(n-1)}
          <a target="_blank" href={@booked |> Enum.at(n-1)}>
            See or cancel this booking.
          </a><br/>
        {/if}

        {#if length(body_areas @limbs[n]) == 0}
          on no specific location on body.
          {#if !@booked}
            (<a href="#" :on-click="begin_choosing_limbs" phx-value-num={n}>
            change</a>){/if}
        {#else}
        on:
        {#if !@booked}
          (<a href="#" :on-click="begin_choosing_limbs" phx-value-num={n}>
          change</a>){/if}
        <ul>{#for area <- body_areas(@limbs[n])}
          <li>{area}</li>
          {/for}</ul>
        {/if}

        <br/>Add-ons:<br/>
        {#if !@booked}
          {#for addon <- @all_addons}
            <button :on-click="addon" phx-value-num={n} phx-value-addon={addon["id"]}
              class={"btn", "join-item", "btn-sm",
              "btn-active": Enum.member?(@addons[n] || [], addon["id"]) } >
              <span>${addon["price"]}</span> /
              <span>{addon["name"]}</span>
            </button>
          {/for}
        {#else}
          <ul>{#for addon <- ((@addons[n] || [])
            |> Enum.map(fn key -> @all_addons |> Enum.find(& &1["id"] == key) end)) }
            <li><span>${addon["price"]}</span> / <span>{addon["name"]}</span></li>
          {#else}(none){/for}
          </ul>
        {/if}
      </li>
    {/for}
    </ul>

    {#if (@services |> chosen_services |> map_size) > 0}
      Once your appointments have ended, you'll be charged a sum of: <br/>
      ${sum_services(chosen_services(@services)) + sum_addons(@addons, @all_addons)}
      (plus taxes)
    {/if}
    """
  end
end
