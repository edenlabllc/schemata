defmodule Schemata.Validators.RequiredItemsTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when all required items are present" do
    test "returns :ok" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   definitions: %{
                     b: object(%{c: integer()}),
                     a: object(%{b: array(ref("b"))}),
                     item: object(%{a: ref("a")})
                   },
                   properties: %{
                     items:
                       array(ref("item"),
                         callbacks: [required_items(["a", "b", "c"], [1, 2])]
                       )
                   }
                 },
                 %{
                   "items" => [
                     %{"a" => %{"b" => [%{"c" => 1}]}},
                     %{"a" => %{"b" => [%{"c" => 2}]}}
                   ]
                 }
               )
    end
  end

  describe "when some required items are not present" do
    test "returns :ok" do
      assert {:error,
              [
                {%{
                   description: "Some of required items are not present: [2]",
                   params: %{required_items: [2]},
                   raw_description: "Some of required items are not present: [%{required_items}]",
                   rule: :required_items
                 }, "$.items"}
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   definitions: %{
                     b: object(%{c: integer()}),
                     a: object(%{b: array(ref("b"))}),
                     item: object(%{a: ref("a")})
                   },
                   properties: %{
                     items:
                       array(ref("item"),
                         callbacks: [required_items(["a", "b", "c"], [1, 2])]
                       )
                   }
                 },
                 %{
                   "items" => [
                     %{"a" => %{"b" => [%{"c" => 1}]}}
                   ]
                 }
               )
    end
  end
end
