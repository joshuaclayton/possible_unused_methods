defmodule PossibleUnusedMethods do
  alias PossibleUnusedMethods.ParallelMap
  alias PossibleUnusedMethods.TagsParser
  alias PossibleUnusedMethods.TokenLocator

  import PossibleUnusedMethods.FileAnalytics, only: [with_only_one_occurrence: 1, without_classes: 1]

  def main(_args) do
    File.read!("#{File.cwd!}/.git/tags")
    |> TagsParser.parse
    |> generate_terms_with_occurrences
    |> with_only_one_occurrence
    |> without_classes
    |> gather_terms
    |> Enum.join("\n")
    |> IO.puts
  end

  defp generate_terms_with_occurrences(tags_list) do
    tags_list
    |> ParallelMap.map(&TokenLocator.run/1, &Map.merge/2)
  end

  defp gather_terms(terms_and_occurrences) do
    terms_and_occurrences
    |> Map.keys
    |> Enum.sort
  end
end
