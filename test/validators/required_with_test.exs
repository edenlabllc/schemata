defmodule Schemata.Validators.RequiredWithTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when all values are present" do
    test "returns :ok" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     property:
                       object(
                         %{
                           value_a: string(null: true),
                           value_b: string(null: true)
                         },
                         callbacks: [
                           required_with(:value_a, :value_b)
                         ]
                       )
                   }
                 },
                 %{
                   "property" => %{
                     "value_a" => "a",
                     "value_b" => "b"
                   }
                 }
               )
    end
  end

  describe "when all values are missed" do
    test "returns :ok" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     property:
                       object(
                         %{
                           value_a: string(null: true),
                           value_b: string(null: true)
                         },
                         callbacks: [
                           required_with(:value_a, :value_b)
                         ]
                       )
                   }
                 },
                 %{
                   "property" => %{
                     "value_a" => nil,
                     "value_b" => nil
                   }
                 }
               )
    end
  end

  describe "when one value is missed" do
    test "returns {:error, [...]}" do
      assert {:error,
              [
                {
                  %{
                    description: "Field 'value_a' is required when 'value_b' is present",
                    params: %{field: "value_a", required_with_field: "value_b"},
                    raw_description:
                      "Field '%{field}' is required when '%{required_with_field}' is present",
                    rule: :required
                  },
                  "$.property.value_a"
                }
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     property:
                       object(
                         %{
                           value_a: string(null: true),
                           value_b: string(null: true)
                         },
                         callbacks: [
                           required_with(:value_a, :value_b)
                         ]
                       )
                   }
                 },
                 %{
                   "property" => %{
                     "value_b" => "b"
                   }
                 }
               )
    end
  end
end
