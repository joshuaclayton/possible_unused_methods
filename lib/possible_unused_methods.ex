defmodule PossibleUnusedMethods do
  def main(_args) do
    File.read!("#{File.cwd!}/.git/tags")
    |> PossibleUnusedMethods.TagsParser.parse
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
    |> Peach.handle(&PossibleUnusedMethods.Parser.run/1, &Map.merge/2)
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

defmodule Peach do
  def handle(list, function, merge_function) do
    lists = list |> Enum.chunk(div(list |> length, 16))

    current = self()

    lists
    |> Enum.map(fn(list) ->
      spawn_link Peach, :wrapper, [current, list, function]
    end)

    receive_loop([], lists |> length, merge_function)
  end

  def wrapper(pid, list, function) do
    send(pid, {:ok, function.(list)})
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
  end

  defp add_to(term, acc) do
    acc ++ [term]
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
