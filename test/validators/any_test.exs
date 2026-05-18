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
                {%{
                   description: "String does not match pattern '^[1-9]+$'",
                   params: %{value: "1a", pattern: "^[1-9]+$"},
                   rule: :regexs,
                   raw_description: "String does not match pattern '%{pattern}'"
                 }, "$.string"}
              ]} ==
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
                 %{"string" => "1a"}
               )
    end
  end
end
