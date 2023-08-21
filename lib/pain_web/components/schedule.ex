defmodule PainWeb.Components.Schedule do
  use Surface.Component
  import Pain.Schedule

  prop day, :string, default: today() |> Date.to_string()
  prop block, :string, default: nil
  prop keys, :list
  prop done, :event

  def handle_event("day", params, socket) do
    { :noreply, assign(socket, :day, params["value"]) }
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
      .schedule {
        display: flex;
        justify-content: space-around;
      }
      .schedule > * { margin: 0.6rem; }
    </style>

    Please schedule:

    <section class="schedule">
      <div phx-update="ignore">
        <input type="text" id="calendar" :hook="Calendar"
          data-day={today()}
          data-possible={message() |> check_blocks(@keys,
          [ 7733522, 4351609, 8178118, 7733431, 7733550, 7822447, 7832226, ],
          hd(bookable_months())
          ) |> Jason.encode! }
        />
      </div>
      <div>
        Please choose a block of time on {@day}.
      </div>
    </section>
    """
  end
end
