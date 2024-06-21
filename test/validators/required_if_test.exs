defmodule Schemata.Validators.RequiredIfTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when value is present and condition works" do
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
                           required_if(:value_a, :value_b, "b")
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

  describe "when all values are missed and condition doesn't work" do
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
                           required_if(:value_a, :value_b, "b")
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

  describe "when required value is missed and condition works" do
    test "returns {:error, [...]}" do
      assert {:error,
              [
                {
                  %{
                    description: "Field 'value_a' is required when 'value_b' = " <> _,
                    params: %{
                      field: "value_a",
                      required_if_field: "value_b",
                      required_if_value: "b"
                    },
                    raw_description:
                      "Field '%{field}' is required when '%{required_if_field}' = %{required_if_value}",
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
                           required_if(:value_a, :value_b, "b")
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
