defmodule PainWeb.Components.Schedule do
  use Surface.LiveComponent
  import Pain.Schedule

  prop service_keys, :list, default: []
  prop employee_keys, :list, default: []

  data possible_by_day, :map, default: %{}
  data services, :list, default: []
  data employees, :list, default: []
  data day, :string
  data block, :string, default: nil

  def mount(socket),
    do: {:ok, socket |> assign(:day, today() |> Date.to_string) }

  def update(assigns, socket) do
    {:ok, socket
    |> assign(:services, assigns[:service_keys])
    |> assign(:employees, assigns[:employee_keys])
    |> assign(:possible_by_day, message() |> check_blocks(
      assigns[:service_keys], assigns[:employee_keys], this_month()))
    }
  end

  def handle_event("schedule_day", params, socket) do
    {:noreply, assign(socket, :day, params["day"])}
  end

  def handle_event("schedule_month", params, socket) do
    {:noreply, socket
    |> assign(:possible_by_day,
      message() |> check_blocks(
        socket.assigns[:services],
        socket.assigns[:employees],
        month("#{params["year"]}-#{params["month"]}"))
    )
    |> push_event("color", %{})
    }
  end

  def open_blocks possible_by_day, day do
    case (
      possible_by_day
      |> Enum.filter(&(length(&1) > 0))
      |> Enum.filter(&( (&1 |> hd |> String.split("T") |> hd) == day))
    ) do
      [] -> []
      [blocks] -> blocks
    end
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
      .inline {
        display: flex;
        justify-content: space-around;
      }
      .inline > * { margin: 0.6rem; }
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
          Please choose a block of time on {@day}.
          {#for block <- (@possible_by_day
            |> open_blocks(@day)
            |> Enum.map(&( Regex.scan(~r/\d{2}:\d{2}/, &1) |> hd |> hd))
          )}
            <div>{block}</div>
          {/for}
        </div>
      </div>
    </section>
    """
  end
end
