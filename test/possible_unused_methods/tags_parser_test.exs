defmodule PossibleUnusedMethods.TagsParserTest do
  use ExUnit.Case
  doctest PossibleUnusedMethods

  @tags_file_contents """
user_not_authenticated	../app/controllers/api/base_controller.rb	/^    def user_not_authenticated$/;"	f	class:Api.BaseController
user_not_authorized	../app/controllers/api/base_controller.rb	/^    def user_not_authorized$/;"	f	class:Api.BaseController
user_policy_with_different_user_as_actor	../spec/policies/user_policy_spec.rb	/^  def user_policy_with_different_user_as_actor$/;"	f
user_policy_with_missing_actor	../spec/policies/user_policy_spec.rb	/^  def user_policy_with_missing_actor$/;"	f
user_policy_with_owner_as_actor	../spec/policies/user_policy_spec.rb	/^  def user_policy_with_owner_as_actor$/;"	f
  """

  test "extracting tokens" do
    tags_list = @tags_file_contents |> PossibleUnusedMethods.TagsParser.parse

    assert tags_list == [
      "user_not_authenticated",
      "user_not_authorized",
      "user_policy_with_different_user_as_actor",
      "user_policy_with_missing_actor",
      "user_policy_with_owner_as_actor"
    ]
  end
end
