defmodule Pain.Order do
  import Pain.Schedule, only: [headers: 0]

  @doc """

  order = %{
    schedule: "2023-09-09T15:00",
    employed: %{1 => "_fem", 2 => "_masc", 3 => "Andy Ji", 4 => "Bin Wang"},
    customer: %{ "email" => "mail@assembled.app", "name" => "Zi", "phone" => "222-333-4444", "reference" => "", "surname" => "Ao" },
    limbs: %{2 => ["Front / Left pectoral", "Front / Abs"]},
  }

  cs = PainWeb.BookLive.chosen_services(%{
    1 => "90Min Reflexology with Chinese Medicine",
    2 => "90min Massage", 3 => "Cupping", 4 => "Wet Cupping"
  })

  IEx.Helpers.recompile
  order |> Pain.Order.book(cs)

  """
  def book order, services, addons do
    address = "https://acuityscheduling.com/api/v1/appointments?admin=true" # <> "&noEmail=true"

    services
    |> Enum.sort_by(fn {n, _} -> employee_key(order[:employed][n]) end)
    |> Enum.map(fn {n, service} ->
      [name, surname] = case order[:customer]["name"] |> String.split(" ") do
        [n | []] -> [n,"_"]
        [n | [s]] -> [n, s]
      end
      body = %{
        datetime: order[:schedule],
        appointmentTypeID: service["schedule_key"],
        firstName: name,
        lastName: surname,
        email: order[:customer]["email"],
        phone: order[:customer]["phone"],
        notes: compile_remarks(order[:employed][n], order[:limbs][n]),
        addonIDs: addons[n],
        smsOptIn: true,
      }
      body = case employee_key(order[:employed][n]) do
        nil -> body
        key -> body |> Map.put(:calendarID, key)
      end
      |> IO.inspect |> Jason.encode!

      case (HTTPoison.post!(address, body, headers()) |> Map.get(:body) |> Jason.decode) do
        {:error, r} -> IO.inspect r; "/error"
        {:ok, r = %{"status_code" => 400}} -> IO.inspect r; "/error"
        {:ok, r } -> r["confirmationPagePaymentLink"]
      end
    end)
  end

  def employee_key name do
    (case name do

      "_any" ->
        PainWeb.BookLive.all_employees()
        # |> Enum.filter(fn e -> true end)
        # Pain.Schedule.employee_is_bookable?(e, schedule)
        |> Enum.random()

      "_" <> gender ->
        PainWeb.BookLive.all_employees()
        |> Enum.filter(&(&1["gender"] |> String.starts_with?(gender)))
        # |> Enum.filter(fn e -> true end)
        |> Enum.random()

      n -> PainWeb.BookLive.all_employees() |> Enum.find(&(&1["name"] == n))

    end)["schedule_key"]
  end

  def compile_remarks(employed, limbs) do
    employee = case employed do
      "_masc" -> "Masculine employee"
      "_fem" -> "Feminine employee"
      "_any" -> "Any employee"

      name -> name
    end
    locacion = case limbs do
      nil -> nil
      [] -> nil
      l -> Enum.map(l, fn limb ->
          case limb do
            nil -> nil
            "" -> nil
            "_choose" -> nil
            place -> "Body location: " <> place
          end
      end) |> Enum.join("\n")
    end

    [employee, locacion] |> Enum.filter(& !is_nil(&1)) |> Enum.join("\n\n")
  end
end
