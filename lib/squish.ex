defmodule Squish do
  def squish([]), do: []
  def squish([head | tail]) when is_list(head), do: head ++ squish(tail)
  def squish([head | tail]), do: [head] ++ squish(tail)

  def pare(text, opts \\ []) do
    size = opts[:size] || 50
    omission = opts[:omission] || "..."

    cond do
      not String.valid?(text) -> text
      String.length(text) < size -> text
      true ->
        length_with_omission = size - String.length(omission)
        "#{String.slice(text, 0, length_with_omission)}#{omission}"
    end
  end
end
