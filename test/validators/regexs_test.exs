defmodule Schemata.Validators.RegexsTest do
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
                           regexs([~r/^[A-Z1-9\.]+$/ui, ~r/^[1-9]/ui, {:not, ~r/\.$/ui}])
                         ]
                       )
                   }
                 },
                 %{"string" => "1.value"}
               )
    end
  end

  describe "when schema does not match the should match rule" do
    test "returns {:error, [...]}" do
      assert {:error,
              [
                {%{
                   description: "String does not match pattern '^[1-9]'",
                   params: %{value: "value.1", pattern: "^[1-9]"},
                   raw_description: "String does not match pattern '%{pattern}'",
                   rule: :regexs
                 }, "$.string"}
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     string:
                       string(
                         callbacks: [
                           regexs([~r/^[A-Z1-9\.]+$/ui, ~r/^[1-9]/ui, {:not, ~r/\.$/ui}])
                         ]
                       )
                   }
                 },
                 %{"string" => "value.1"}
               )
    end
  end

  describe "when schema matches the should not match rule" do
    test "returns {:error, [...]}" do
      assert {:error,
              [
                {%{
                   description: ~S(String matches pattern '\.$' but it should not),
                   params: %{value: "1value.", pattern: ~S(\.$)},
                   raw_description: "String matches pattern '%{pattern}' but it should not",
                   rule: :regexs
                 }, "$.string"}
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     string:
                       string(
                         callbacks: [
                           regexs([~r/^[A-Z1-9\.]+$/ui, ~r/^[1-9]/ui, {:not, ~r/\.$/ui}])
                         ]
                       )
                   }
                 },
                 %{"string" => "1value."}
               )
    end
  end

  describe "when value is not set" do
    test "returns :ok" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     string:
                       string(
                         callbacks: [
                           regexs([~r/^[A-Z1-9\.]+$/ui, ~r/^[1-9]/ui, {:not, ~r/\.$/ui}])
                         ]
                       )
                   }
                 },
                 %{}
               )
    end
  end
end
