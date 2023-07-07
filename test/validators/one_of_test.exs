defmodule Schemata.Validators.OneOfTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when schema matches" do
    test "returns :ok" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo:
                       one_of([
                         object(
                           %{last_name: string()},
                           required: [:last_name]
                         ),
                         object(
                           %{surname: string()},
                           required: [:surname]
                         )
                       ])
                   }
                 },
                 %{"foo" => %{"last_name" => "Шевченко"}}
               )
    end
  end

  describe "when schema does not match" do
    test "returns {:error, [...]}" do
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
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo:
                       one_of([
                         object(
                           %{last_name: string()},
                           required: [:last_name]
                         ),
                         object(
                           %{surname: string()},
                           required: [:surname]
                         )
                       ])
                   }
                 },
                 %{"foo" => %{"first_name" => "Тарас"}}
               )
    end
  end
end
