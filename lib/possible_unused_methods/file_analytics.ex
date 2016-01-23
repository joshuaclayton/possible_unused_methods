defmodule PossibleUnusedMethods.FileAnalytics do
  def with_only_one_occurrence(terms_and_occurrences) do
    terms_and_occurrences
    |> find_occurrences_in_only_one_file
    |> find_occurrences_on_only_one_line
  end

  def without_classes(terms_and_occurrences) do
    terms_and_occurrences
    |> select(fn term, _files_with_occurrences ->
      !(term |> String.match?(~r/^[A-Z]/))
    end)
  end

  defp find_occurrences_in_only_one_file(terms_and_occurrences) do
    terms_and_occurrences
    |> select(fn _term, files_with_occurrences ->
      files_with_occurrences |> Map.size == 1
    end)
  end

  defp find_occurrences_on_only_one_line(terms_and_occurrences) do
    terms_and_occurrences
    |> select(fn _term, files_with_occurrences ->
      files_with_occurrences |> Map.values |> Enum.sort |> Enum.at(0) == 1
    end)
  end

  defp select(map, function) do
    map
    |> Enum.reduce(%{}, fn({key, value}, acc) ->
      function.(key, value)
      |> select_filter(acc, key, value)
    end)
  end

  defp select_filter(true, acc, key, value), do: put_in acc, [key], value
  defp select_filter(false, acc, _key, _value), do: acc
end
