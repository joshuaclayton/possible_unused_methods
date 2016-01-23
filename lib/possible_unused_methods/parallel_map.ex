defmodule PossibleUnusedMethods.ParallelMap do
  def map(list, function, merge_function, groups \\ 16) do
    current = self()
    chunk_count = div(list |> length, groups)
    lists = list |> Enum.chunk(chunk_count, chunk_count, [])

    lists
    |> Enum.each(fn(list) ->
      spawn_link fn ->
        send current, {:ok, function.(list)}
      end
    end)

    receive_loop([], lists |> length, merge_function)
  end

  defp receive_loop(data, remaining_completes, merge_function) when remaining_completes > 0 do
    receive do
      {:ok, datum} ->
        receive_loop(data ++ [datum], remaining_completes - 1, merge_function)
    end
  end

  defp receive_loop(data, 0, merge_function) do
    data |> Enum.reduce(merge_function)
  end
end
