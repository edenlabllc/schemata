defmodule Schemata.Validators.ObjectUniqByTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when schema matches" do
    test "returns :ok when value is a key" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     list: array(nil, callbacks: [object_uniq_by("key")])
                   }
                 },
                 %{"list" => [%{"key" => "key_1"}, %{"key" => "key_2"}]}
               )
    end

    test "returns :ok when value is a function" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     list: array(nil, callbacks: [object_uniq_by(&Map.get(&1, "key"))])
                   }
                 },
                 %{"list" => [%{"key" => "key_1"}, %{"key" => "key_2"}]}
               )
    end
  end

  describe "when schema does not match" do
    test "returns error when value is a binary" do
      assert [
               {%{
                  description: "Values are not unique by 'key'.",
                  params: %{value: "key", values: [%{"key" => "key_1"}, %{"key" => "key_1"}]},
                  raw_description: ~S(Values are not unique by '#{value}'.),
                  rule: :object_uniq_by
                }, "$.list"}
             ] =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     list: array(nil, callbacks: [object_uniq_by("key")])
                   }
                 },
                 %{"list" => [%{"key" => "key_1"}, %{"key" => "key_1"}]}
               )
    end

    test "returns error when value is a function" do
      assert [
               {%{
                  description: "Values are not unique.",
                  params: %{value: nil, values: [%{"key" => "key_1"}, %{"key" => "key_1"}]},
                  raw_description: "Values are not unique.",
                  rule: :object_uniq_by
                }, "$.list"}
             ] =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     list: array(nil, callbacks: [object_uniq_by(&Map.get(&1, "key"))])
                   }
                 },
                 %{"list" => [%{"key" => "key_1"}, %{"key" => "key_1"}]}
               )
    end
  end

  describe "when value is not set" do
    test "returns :ok" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     list: array(nil, callbacks: [object_uniq_by(&Map.get(&1, "key"))])
                   }
                 },
                 %{}
               )
    end
  end
end
