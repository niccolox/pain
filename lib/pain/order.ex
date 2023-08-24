defmodule Pain.Order do
  import Pain.Schedule, only: [headers: 0]

  @doc """

  %{
    number: 4,
    services: %{
      1 => "90Min Reflexology with Chinese Medicine",
      2 => "90min Massage",
      3 => "Cupping",
      4 => "Wet Cupping"
    },
    schedule: "2023-08-28T14:00",
    employed: %{1 => "_fem", 2 => "_masc", 3 => "Andy Ji", 4 => "Bin Wang"}
  }

  """
  def book order do
    order |> IO.inspect
  end
end
