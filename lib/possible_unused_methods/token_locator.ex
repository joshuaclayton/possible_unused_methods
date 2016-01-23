defmodule PossibleUnusedMethods.TokenLocator do
  @moduledoc """
  Searches a given codebase for a list of tokens using The Silver Searcher
  (https://github.com/ggreer/the_silver_searcher).

  This returns a map with tokens mapped to a map of files and the number of
  occurrences per file:

  %{
    "first_name" => %{
      "app/models/user.rb" => 1,
      "app/views/users/_user.html.erb" => 1
      "app/views/users/_form.html.erb" => 2
    },
    "last_name" => %{
      "app/models/user.rb" => 1,
      "app/views/users/_user.html.erb" => 1
      "app/views/users/_form.html.erb" => 2
    }
  }

  NOTICE:
  This uses :os.cmd to run the command in raw form and is interpolating
  user-generated values. Use at your own risk.
  """

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
      [line | count] = item |> String.split(":")

      put_in(acc, [line], count |> Enum.at(0) |> String.to_integer)
    end)
  end
end
