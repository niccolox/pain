defmodule Parallel do
  def map(collection, fun) do
    main = self()
    collection
    |> Enum.map(fn (elem) -> spawn_link fn -> (send main, { self(), fun.(elem) }) end end)
    |> Enum.map(fn (pid) -> receive do { ^pid, response } -> response end end)
  end
end
