defmodule Squish do
  def squish([]), do: []
  def squish([head | tail]) when is_list(head), do: head ++ squish(tail)
  def squish([head | tail]), do: [head] ++ squish(tail)
end
