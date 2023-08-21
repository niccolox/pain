defmodule PainWeb.Components.Schedule do
  use Surface.Component
  import Pain.Schedule

  data month, :string, default: "2023-08"
  data day, :string, default: nil
  data hour, :string, default: nil

  prop keys, :list
  prop done, :event

  def render(assigns) do
    if !assigns[:day], do: render_days(assigns), else: render_hours(assigns)
  end

  def render_days(assigns) do
    ~F"""
    <style>
      input {
        border: 1px solid #426;
        border-radius: 0.4rem;
        padding: 0.6rem;
        text-align: center;
      }
    </style>

    <section class="schedule">
      Please schedule:

      <div>
        <input type="text" id="calendar" :hook="Calendar"
          data-day={today()}
          data-possible={message() |> check_blocks(@keys,
          [ 7733522, 4351609, 8178118, 7733431, 7733550, 7822447, 7832226, ],
          hd(bookable_months())
          ) |> Jason.encode! }
        />
      </div>
    </section>
    """
  end

  def render_hours(assigns) do
    ~F"""
    Choose a time:
    """
  end
end
