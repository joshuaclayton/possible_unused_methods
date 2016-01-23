defmodule PossibleUnusedMethods do
  alias PossibleUnusedMethods.ParallelMap
  alias PossibleUnusedMethods.TagsParser
  alias PossibleUnusedMethods.TokenLocator

  def main(_args) do
    File.read!("#{File.cwd!}/.git/tags")
    |> TagsParser.parse
    |> generate_terms_with_occurrences
    |> find_occurrences_in_only_one_file
    |> find_occurrences_on_only_one_line
    |> remove_occurrences_that_look_like_classes
    |> gather_terms
    |> Enum.join("\n")
    |> IO.puts
  end

  defp generate_terms_with_occurrences(tags_list) do
    tags_list
    |> ParallelMap.map(&TokenLocator.run/1, &Map.merge/2)
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
      files_with_occurrences |> Map.values |> Enum.at(0) == 1
    end)
  end

  defp remove_occurrences_that_look_like_classes(terms_and_occurrences) do
    terms_and_occurrences
    |> select(fn term, _files_with_occurrences ->
      !(term |> String.match?(~r/^[A-Z]/))
    end)
  end

  defp gather_terms(terms_and_occurrences) do
    terms_and_occurrences
    |> Map.keys
    |> Enum.sort
  end

  defp select(map, function) do
    map
    |> Enum.reduce(%{}, fn({key, value}, acc) ->
      case function.(key, value) do
        true -> put_in acc, [key], value
        false -> acc
      end
    end)
  end
end
