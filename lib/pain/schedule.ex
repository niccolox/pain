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

  def bookable_months do
    1..3
    |> Enum.reduce([DateTime.utc_now |> DateTime.to_date], fn _, months ->
      prior = months |> Enum.reverse() |> hd()
      months ++ [
        prior
        |> Date.add(31)
        |> Date.beginning_of_month()
      ]
    end)
    |> Enum.reduce([], fn beginning, months ->
      months ++ [Date.range(beginning, Date.end_of_month(beginning)) ]
    end)
  end

  @doc """
  days = Pain.Schedule.message |> Pain.Schedule.check_blocks(
    [ 39928578, 39928780, 39928578, ],
    [ 7733522, 4351609, 8178118, 7733431, 7733550, 7822447, 7832226, ],
    hd(Pain.Schedule.bookable_months())
  )
  """
  def check_blocks headers, scheduling_keys, employee_keys, range do
    keys = scheduling_keys |> Enum.reduce(%{}, fn x, acc ->
      Map.update(acc, x, 1, &(&1 + 1)) end)

    responses = (range |> Enum.map(fn day ->
      if day < (DateTime.utc_now() |> DateTime.to_date()), do: [], else:
      keys |> Enum.map(fn { key, demand } ->
        response = employee_keys |> Enum.map(fn employee ->
          search_hours = "https://acuityscheduling.com/api/v1/availability/times?date=#{day}&appointmentTypeID=#{key}&calendarID=#{employee}"
          HTTPoison.get!(search_hours, headers) |> Map.get(:body) |> Jason.decode!
        end)
        |> reduce_calendars
        |> Enum.filter(fn { _, num } -> num >= demand end)
        |> Enum.map(fn { block, _ } -> block end)
      end)
      |> reduce_blocks
    end))
    |> Enum.map(&(%{ (&1 |> hd |> String.split(" ")) => length &1 }))

    # responses |> Enum.filter(&(length(&1) > 0))
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
