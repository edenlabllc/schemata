defmodule Schemata.Validators.OneOfTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when schema matches" do
    test "returns :ok" do
      assert :ok ==
               %Schema{properties: %{foo: one_of([enum(["a", "b"]), enum(["c", "d"])])}}
               |> SchemaValidator.validate(%{"foo" => "a"})
    end
  end

  describe "when schema does not match" do
    test "returns :ok" do
      assert {:error,
              [
                {%{
                   description:
                     "expected exactly one of the schemata to match, but none of them did",
                   params: %{},
                   raw_description:
                     "expected exactly one of the schemata to match, but none of them did",
                   rule: :schemata
                 }, "$.foo"}
              ]} ==
               %Schema{properties: %{foo: one_of([enum(["a", "b"]), enum(["c", "d"])])}}
               |> SchemaValidator.validate(%{"foo" => "e"})
    end
  end
end
