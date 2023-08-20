defmodule PainWeb.Components.Schedule do
  use Surface.Component
  alias Phoenix.LiveView.JS

  data month, :string, default: Pain.Schedule.month() # "2023-09"
  data day, :string, default: nil
  data hour, :string, default: nil

  prop keys, :list
  prop done, :event

  def schedule_days assigns do
    assigns[:keys]
    |> Enum.map(&(Pain.Schedule.message |> Pain.Schedule.check_days(&1)))
  end

  def schedule_hours assigns do
    assigns[:keys]
    |> Enum.map(&(Pain.Schedule.message |> Pain.Schedule.check_hours(&1)))
  end

  def render(assigns) do
    if !assigns[:day], do: render_days(assigns), else: render_hours(assigns)
  end

  def render_days(assigns) do
    # if length(assigns[:keys]) > 0, do: IO.inspect schedule_days assigns
    # if length(assigns[:keys]) > 0, do: IO.inspect schedule_hours assigns

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
          data-day={Pain.Schedule.day()}
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
