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

  def day, do: DateTime.utc_now |> DateTime.to_string |> String.split(" ") |> hd
  def month, do: day() |> String.split("-") |> Enum.take(2) |> Enum.join("-")

  def check_days headers, scheduling_key do
    check_days headers, scheduling_key, month()
  end

  def check_days headers, scheduling_key, month do
    choose_day =  "https://acuityscheduling.com/api/v1/availability/dates?month=#{month}&appointmentTypeID=#{scheduling_key}"
    HTTPoison.get!(choose_day, headers) |> Map.get(:body) |> Jason.decode!
  end

  def check_hours headers, scheduling_key do
    [day, _] = DateTime.utc_now |> DateTime.to_string |> String.split(" ")
    check_hours headers, scheduling_key, day
  end

  def check_hours headers, scheduling_key, day do
    choose_hour =  "https://acuityscheduling.com/api/v1/availability/times?date=#{day}&appointmentTypeID=#{scheduling_key}"
    HTTPoison.get!(choose_hour, headers) |> Map.get(:body) |> Jason.decode!
  end
end
