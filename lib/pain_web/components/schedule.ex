defmodule PainWeb.Components.Schedule do
  use Surface.LiveComponent
  import Pain.Schedule

  prop service_keys, :list, default: []
  prop employee_keys, :list, default: []
  prop schedule, :event, required: true

  data possible_by_day, :map, default: %{}
  data day, :string
  data block, :string, default: nil

  def mount(socket),
    do: {:ok, socket |> assign(:day, today() |> Date.to_string) }

  def update(assigns, socket) do
    {:ok, socket
    |> assign(assigns)
    |> assign(:possible_by_day, check_blocks(
      service_demand(assigns[:service_keys]),
      assigns[:employee_keys],
      this_month())
    )}
  end

  def handle_event("schedule_day", params, socket) do
    {:noreply, assign(socket, :day, params["day"])}
  end

  def handle_event("schedule_month", params, socket) do
    {:noreply, socket
    |> assign(:possible_by_day, check_blocks(
      socket.assigns[:service_keys],
      socket.assigns[:employee_keys],
      month("#{params["year"]}-#{params["month"]}")))
    |> push_event("color", %{})
    }
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
      .inline { display: flex; justify-content: space-around; }
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
        border: 1px solid lightgrey;
      }
      .hour > span { grid-column: 1; grid-row: 1 / -1; font-weight: 600; }
      .hour > .min { grid-column: 2; text-decoration: underline; cursor: pointer; }
    </style>

    <section class="schedule" data-day={today()} data-possible={
      @possible_by_day
      |> Enum.filter(&(length(&1) > 0))
      |> Enum.reduce(%{}, fn day, all ->
        Map.put(all, (day |> hd |> String.split("T") |> hd), length day)
      end) |> Jason.encode! } >
      <h4>Please schedule:</h4>

      <div class="inline">
        <div phx-update="ignore">
          <input type="text" id="calendar" :hook="Calendar" phx-target={@myself} />
        </div>
        <div>
          {#if length(@possible_by_day |> open_blocks(@day)) == 0}
            There are no more openings on {@day}.
          {#else}
            Please choose a block of time on {@day}.
            <div class="blocks">
              {#for {hour, mins} <- (@possible_by_day |> open_blocks(@day) |> hour_map())}
                <div class="hour"><span>{hour}:</span>
                {#for min <- mins}
                  <div role="link" class="min" :on-click={@schedule}
                    phx-value-shape={"#{@day}T#{hour}:#{min}" <> ending()}>
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
