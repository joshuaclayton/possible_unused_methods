defmodule PossibleUnusedMethods.TagsParser do
  def parse(lines) do
    lines
    |> String.split("\n")
    |> Enum.reduce([], fn(line, acc) ->
      line
      |> String.split("\t")
      |> Enum.at(0)
      |> add_to(acc)
    end)
    |> Enum.uniq
    |> Enum.reject(fn(item) -> item == "" end)
  end

  defp add_to(term, acc) do
    acc ++ [term]
  end
end
