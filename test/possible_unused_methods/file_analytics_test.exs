defmodule PossibleUnusedMethods.FileAnalyticsTest do
  use ExUnit.Case
  alias PossibleUnusedMethods.FileAnalytics

  doctest PossibleUnusedMethods

  test "finding results with only one occurrence" do
    results = %{
      "found_all_over" => %{
        "file_1" => 2,
        "file_2" => 1,
      },
      "found_multiple_times_in_one_file" => %{
        "file_1" => 9,
      },
      "found_once_in_one_file" => %{
        "file_1" => 1,
      }
    }

    assert FileAnalytics.with_only_one_occurrence(results) == %{
      "found_once_in_one_file" => %{
        "file_1" => 1,
      }
    }
  end

  test "filtering out what looks like classes" do
    results = %{
      "ClassName" => %{
        "file_1" => 2,
        "file_2" => 1,
      },
      "non_class_name" => %{
        "file_1" => 1,
      }
    }

    assert FileAnalytics.without_classes(results) == %{
      "non_class_name" => %{
        "file_1" => 1,
      }
    }
  end
end
