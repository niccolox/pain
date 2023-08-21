defmodule Pain.Schedule do
  def message do
    auth = (
      ["SCHEDULE_USER", "SCHEDULE_KEY"]
      |> Enum.map(&System.get_env/1)
      |> Enum.join(":")
      |> Base.encode64
    )
    [ "Authorization": "Basic #{auth}", "Accept": "application/json" ]
  end

  def today, do: now() |> DateTime.to_date()
  def now do
    # On initial app load, tzdata needs to pull time zones,
    # meaning the only time zone on launch is UTC.
    # Proper time zones are loaded prior to any calls,
    # though a backup is needed to compile `PainWeb.Components.Schedule`.
    case DateTime.now("America/New_York") do
      {:ok, c } -> c
      {:error, _ } -> DateTime.utc_now()
    end
  end

  def this_month do
    Date.range(today(), today() |> Date.end_of_month)
  end

  def month(month) do
    [y,m] = month |> String.split("-") |> Enum.map(&String.to_integer/1)
    beginning = Date.new(y,m,1) |> elem(1) |> Date.beginning_of_month
    Date.range(beginning, beginning |> Date.end_of_month)
  end

  @doc """
  days = Pain.Schedule.message |> Pain.Schedule.check_blocks(
    [ 39928578, 39928780, 39928578, ],
    [ 7733522, 4351609, 8178118, 7733431, 7733550, 7822447, 7832226, ],
    this_month()
  )
  """
  def check_blocks headers, service_keys, employee_keys, range do
    keys = service_keys |> Enum.reduce(%{}, fn x, acc ->
      Map.update(acc, x, 1, &(&1 + 1)) end)
    (range |> Parallel.map(fn day ->
      keys |> Parallel.map(fn { key, demand } ->
        employee_keys |> Enum.map(fn employee ->
          search_hours = "https://acuityscheduling.com/api/v1/availability/times?date=#{day}&appointmentTypeID=#{key}&calendarID=#{employee}"
          case (
            HTTPoison.get!(search_hours, headers) |> Map.get(:body) |> Jason.decode
          ) do
            {:ok, r} -> r
            {:error, m} -> []
          end
        end)
        |> reduce_calendars
        |> Enum.filter(fn { _, num } -> num >= demand end)
        |> Enum.map(fn { block, _ } -> block end)
      end)
      |> reduce_blocks
    end))
  end

  def reduce_calendars calendars do
    calendars |> Enum.reduce(%{}, fn calendar, all ->
      calendar |> Enum.reduce(all, fn calBlock, cal ->
        Map.update(cal, calBlock["time"], 0, &(&1 + calBlock["slotsAvailable"]))
      end)
    end)
  end

  def reduce_blocks [original | remaining] do
    remaining |> Enum.reduce(MapSet.new(original), fn blocks, solid ->
      MapSet.intersection MapSet.new(blocks), solid
    end) |> MapSet.to_list
  end
end
