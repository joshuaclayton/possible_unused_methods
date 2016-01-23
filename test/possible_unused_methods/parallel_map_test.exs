defmodule PossibleUnusedMethods.ParallelMapTest do
  use ExUnit.Case
  doctest PossibleUnusedMethods

  test "mapping results" do
    test_handle = fn(list) ->
      list
      |> Enum.reduce(%{}, fn(item, acc) ->
        put_in acc, [to_string(item)], item
      end)
    end

    result = [1,2,3,4,5,6,7]
             |> PossibleUnusedMethods.ParallelMap.map(test_handle, &Map.merge/2, 3)

    assert result == %{"1" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7}
  end
end
