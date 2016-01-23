defmodule PossibleUnusedMethods do
  alias PossibleUnusedMethods.ParallelMap
  alias PossibleUnusedMethods.TagsParser

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
    |> ParallelMap.map(&PossibleUnusedMethods.Parser.run/1, &Map.merge/2)
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

defmodule PossibleUnusedMethods.Parser do
  def run(items) do
    items
    |> Enum.reject(fn(item) -> item == "" end)
    |> build_matches
  end

  defp build_matches(items) do
    items
    |> Enum.reduce(%{}, fn(item, acc) ->
      put_in acc, [item], matches_for(item)
    end)
  end


  defp matches_for(item) do
    :os.cmd('ag "#{item}" -c -Q')
    |> to_string
    |> String.strip
    |> String.split("\n")
    |> Enum.reject(fn(item) -> item == "" end)
    |> matches_to_map
  end

  defp matches_to_map(matches) do
    matches
    |> Enum.reduce(%{}, fn(item, acc) ->
      IO.puts item
      [line | count] = item |> String.split(":")

      put_in(acc, [line], count |> Enum.at(0) |> String.to_integer)
    end)
  end
end
