defmodule Pain.Schedule do
  def headers do
    auth = (
      ["SCHEDULE_USER", "SCHEDULE_KEY"]
      |> Enum.map(&System.get_env/1)
      |> Enum.join(":")
      |> Base.encode64
    )
    [ "Authorization": "Basic #{auth}", "Accept": "application/json" ]
  end

  def ending, do: ":00Z-04:00"

  def today, do: now() |> DateTime.to_date()
  def now do
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

  def service_demand(service_keys) do
    service_keys
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
  end

  @doc """
  import Pain.Schedule
  check_blocks(
    service_demand([ 39928578, 39928780, 39931669, ]),
    [ 7733522, 4351609, 8178118, 7733431, 7733550, 7822447, 7832226, ],
    this_month())
  """
  def check_blocks demand, employee_keys, range do
    (range |> Parallel.map(fn day ->
      demand |> Parallel.map(fn { service, demand } ->
        check_calendar_day_service(service, employee_keys, day)
        |> reduce_calendars
        |> Enum.filter(fn { _, num } -> num >= demand end)
        |> Enum.map(fn { block, _ } -> block end)
      end)
      |> reduce_blocks
    end))
  end

  def check_calendar_day_service service, employee_keys, day do
    employee_keys |> Enum.map(fn employee ->
      search_hours = "https://acuityscheduling.com/api/v1/availability/times?date=#{day}&appointmentTypeID=#{service}&calendarID=#{employee}"
      case (HTTPoison.get!(search_hours, headers()) |> Map.get(:body) |> Jason.decode) do
        {:error, r} -> IO.inspect r; []
        {:ok, r = %{"status_code" => 400}} -> IO.inspect r; []
        {:ok, r } -> r
      end
    end)
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

  @doc """
  import Pain.Schedule
  check_blocks(
    service_demand([ 39928578, 39928780, 39931669, ]),
    [ 7733522, 4351609, 8178118, 7733431, 7733550, 7822447, 7832226, ],
    this_month())
  |> open_blocks("2023-08-30")
  |> hour_map()
  """
  def hour_map(clocks) do
    clocks
    |> Enum.map(&( Regex.scan(~r/\d{2}:\d{2}/, &1) |> hd |> hd))
    |> Enum.sort()
    |> Enum.reduce(%{}, fn c, by_hour ->
      [h | [m | []]] = c |> String.split(":")
      Map.update(by_hour, h, [m], &(&1 ++ [m]))
    end)
  end
end
