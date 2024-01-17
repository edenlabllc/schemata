defmodule Schemata.Validators.RequiredOneOfTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when there are allowed properties" do
    test "returns :ok" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     property:
                       object(
                         %{
                           value_a: string(),
                           value_b: string(),
                           value_c: string(),
                           value_d: string()
                         },
                         callbacks: [
                           required_one_of([:value_a, :value_b]),
                           required_one_of([:value_c, :value_d])
                         ]
                       )
                   }
                 },
                 %{
                   "property" => %{
                     "value_a" => "a",
                     "value_c" => "c"
                   }
                 }
               )
    end
  end

  describe "when there are more properties than needed" do
    test "returns {:error, [...]}" do
      assert {:error,
              [
                {
                  %{
                    description:
                      "One and only one key is allowed from the list: [value_a, value_b], but the following are present: [value_a, value_b].",
                    params: %{
                      actual: ["value_a", "value_b"],
                      expected_one_of: ["value_a", "value_b"]
                    },
                    raw_description:
                      "One and only one key is allowed from the list: [%{expected_one_of}], but the following are present: [%{actual}].",
                    rule: :required_one_of
                  },
                  "$.property"
                }
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     property:
                       object(
                         %{
                           value_a: string(),
                           value_b: string(),
                           value_c: string(),
                           value_d: string()
                         },
                         callbacks: [
                           required_one_of([:value_a, :value_b]),
                           required_one_of([:value_c, :value_d])
                         ]
                       )
                   }
                 },
                 %{
                   "property" => %{
                     "value_a" => "a",
                     "value_b" => "b",
                     "value_c" => "c"
                   }
                 }
               )
    end
  end

  describe "when there are less properties than needed" do
    test "returns {:error, [...]}" do
      assert {:error,
              [
                {
                  %{
                    description:
                      "One and only one key is allowed from the list: [value_a, value_b], but the following are present: [].",
                    params: %{
                      actual: [],
                      expected_one_of: ["value_a", "value_b"]
                    },
                    raw_description:
                      "One and only one key is allowed from the list: [%{expected_one_of}], but the following are present: [%{actual}].",
                    rule: :required_one_of
                  },
                  "$.property"
                }
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     property:
                       object(
                         %{
                           value_a: string(),
                           value_b: string(),
                           value_c: string(),
                           value_d: string()
                         },
                         callbacks: [
                           required_one_of([:value_a, :value_b]),
                           required_one_of([:value_c, :value_d])
                         ]
                       )
                   }
                 },
                 %{
                   "property" => %{
                     "value_c" => "c"
                   }
                 }
               )
    end
  end
end
