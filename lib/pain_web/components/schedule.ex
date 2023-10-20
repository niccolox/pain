defmodule PainWeb.Components.Schedule do
  use Surface.LiveComponent
  import Pain.Schedule

  prop service_keys, :list, default: []
  prop employee_keys, :list, default: []
  prop schedule, :event, required: true

  data possible, :map, default: %{}
  data day, :string
  data block, :string, default: nil
  data process, :reference, default: nil

  def mount(socket),
    do: {:ok, socket |> assign(:day, today() |> Date.to_string) }

  def update(assigns, socket) do
    {:ok, socket
    |> assign(assigns |> Map.take(~w[ service_keys employee_keys schedule day block process ]a))
    |> assign(
      if assigns[:possible],
        do: %{ possible: Map.merge(socket.assigns[:possible], assigns[:possible]) },
        else: %{ process:
        Task.async(fn -> service_demand(assigns[:service_keys])
        |> check_blocks(assigns[:employee_keys], this_month())
        |> blocks_by_day()
        end) }
    )
    |> push_event("color", %{}) }
  end

  def handle_event("schedule_day", params, socket) do
    {:noreply, socket
    |> assign(:day, params["day"])
    |> assign(
      if socket.assigns[:possible][params["day"]], do: %{}, else:
      %{ process: Task.async(fn ->
        service_demand(socket.assigns[:service_keys])
        |> check_blocks(socket.assigns[:employee_keys], range(day(params["day"])))
        |> blocks_by_day()
      end) })
    }
  end

  def handle_event("schedule_month", params, socket) do
    {:noreply, socket
    |> assign(:process, Task.async(fn ->
      service_demand(socket.assigns[:service_keys])
      |> check_blocks(
        socket.assigns[:employee_keys],
        month("#{params["year"]}-#{params["month"]}")
      )
      |> blocks_by_day()
    end)) }
  end

  def render(assigns) do
    ~F"""
    <style>
      input {
        border: 1px solid #426;
        border-radius: 0.4rem;
        padding: 0.6rem;
        text-align: center;
      }
      .inline { display: flex; justify-content: start; }
      .inline > * { margin: 0.6rem; }
      @media(max-width: 1080px) { .inline {
        flex-direction: column;
      } }

      .blocks { display: flex; flex-wrap: wrap; }
      .hour {
        width: 4rem;
        display: grid;
        grid-template-columns: 1fr 1fr;
        margin: 0.5rem;
        padding: 0.5rem;
        border: 2px solid #d0a1a1;
        border-radius: 4px;
      }
      .hour > span { grid-column: 1; grid-row: 1 / -1; font-weight: 600; }
      .hour > .min { grid-column: 2; text-decoration: underline; cursor: pointer; }
    </style>

    <section class="schedule" data-day={today()} data-possible={
      @possible
      |> Enum.map(fn {d,b} -> {d, length b } end)
      |> Enum.into(%{})
      |> Jason.encode! } >
      <div class="inline">
        <div phx-update="ignore">
          <input type="text" id="calendar" :hook="Calendar" phx-target={@myself} />
        </div>
        <div>
          {#if @process}<span>...loading...</span>
          {#elseif length(@possible[@day] || []) == 0}
            <span>There are no more openings on {@day}.</span>
          {#else}
            <span>Please choose a block of time on {@day}.</span>
            <div class="blocks">
              {#for {hour, mins} <- (@possible[@day] |> hour_map())}
                <div class="hour"><span>{hour}:</span>
                {#for min <- mins}
                  <div role="link" class="min" :on-click={@schedule}
                    phx-value-shape={"#{@day}T#{hour}:#{min}"}>
                    {min}</div>
                {/for}</div>
              {/for}
            </div>
          {/if}
        </div>
      </div>
    </section>
    """
  end
end
