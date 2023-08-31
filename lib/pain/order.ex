defmodule Pain.Order do
  import Pain.Schedule, only: [headers: 0]

  @doc """

  order = %{
    schedule: "2023-09-01T15:00",
    employed: %{1 => "_fem", 2 => "_masc", 3 => "Andy Ji", 4 => "Bin Wang"},
    customer: %{ "email" => "mail@assembled.app", "name" => "Zi", "phone" => "222-333-4444", "reference" => "", "surname" => "Ao" },
    limbs: %{1 => "anyplace"},
  }

  cs = PainWeb.BookLive.chosen_services(%{
    1 => "90Min Reflexology with Chinese Medicine",
    2 => "90min Massage", 3 => "Cupping", 4 => "Wet Cupping"
  })

  IEx.Helpers.recompile
  order |> Pain.Order.book(cs)

  """
  def book order, services do
    address = "https://acuityscheduling.com/api/v1/appointments?admin=true" <> "&noEmail=true"

    services
    |> Enum.sort_by(fn {n, _} -> employee_key(order[:employed][n]) end)
    |> Enum.each(fn {n, service} ->
      body = %{
        datetime: order[:schedule],
        appointmentTypeID: service["schedule_key"],
        firstName: order[:customer]["name"],
        lastName: order[:customer]["surname"],
        email: order[:customer]["email"],
        phone: order[:customer]["phone"],
        notes: compile_remarks(order[:employed][n], order[:limbs][n]),
      }
      body = case employee_key(order[:employed][n]) do
        nil -> body
        key -> body |> Map.put(:calendarID, key)
      end
      |> IO.inspect |> Jason.encode!

      case (HTTPoison.post!(address, body, headers()) |> Map.get(:body) |> Jason.decode) do
        {:error, r} -> IO.inspect r; []
        {:ok, r = %{"status_code" => 400}} -> IO.inspect r; []
        {:ok, r } -> r
      end
    end)
  end

  def employee_key name do
    (case name do
      "_any" -> PainWeb.BookLive.all_employees() |> hd
      "_" <> gender ->
        PainWeb.BookLive.all_employees()
        |> Enum.filter(&(&1["gender"] |> String.starts_with?(gender)))
        |> hd
      n -> PainWeb.BookLive.all_employees() |> Enum.find(&(&1["name"] == n))
    end)["schedule_key"]
  end

  def compile_remarks(employed, limb) do
    employee = case employed do
      "_masc" -> "Any employee, masculine"
      "_fem" -> "Any employee, feminine"
      "_any" -> "Any employee"
      name -> name
    end
    locacion = case limb do
      nil -> nil
      "" -> nil
      "_choose" -> nil
      place -> "Body location: " <> place
    end

    [employee, locacion] |> Enum.filter(& !is_nil(&1)) |> Enum.join("; ")
  end
end
