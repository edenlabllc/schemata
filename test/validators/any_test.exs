defmodule Schemata.Validators.AnyTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when schema matches" do
    test "returns :ok" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     string:
                       string(
                         callbacks: [
                           any([
                             regexs([~r/^[1-9]+$/ui]),
                             regexs([~r/^[a-zA-Z]+$/ui])
                           ])
                         ]
                       )
                   }
                 },
                 %{"string" => "string"}
               )
    end
  end

  describe "when schema does not match" do
    test "returns {:error, [...]}" do
      assert {:error,
              [
                [
                  {%{
                     description:
                       "String does not match pattern '^[1-9]+$'. If your language is 'numbers'",
                     params: %{value: "1a", pattern: "^[1-9]+$"},
                     raw_description:
                       "String does not match pattern '%{pattern}'. If your language is 'numbers'",
                     rule: :regexs
                   }, "$.string"}
                ],
                [
                  {%{
                     description: "String does not match pattern '^[a-zA-Z]+$'",
                     params: %{value: "1a", pattern: "^[a-zA-Z]+$"},
                     raw_description: "String does not match pattern '%{pattern}'",
                     rule: :regexs
                   }, "$.string"}
                ]
              ]} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     string:
                       string(
                         callbacks: [
                           any([
                             {regexs([~r/^[1-9]+$/ui]), "If your language is 'numbers'"},
                             regexs([~r/^[a-zA-Z]+$/ui])
                           ])
                         ]
                       )
                   }
                 },
                 %{"string" => "1a"}
               )
    end
  end
end
