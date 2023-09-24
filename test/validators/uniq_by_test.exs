defmodule Schemata.Validators.UniqByTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when schema matches" do
    test "returns :ok when value is a key" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     list: array(nil, callbacks: [uniq_by("key")])
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
                     list: array(nil, callbacks: [uniq_by(&Map.get(&1, "key"))])
                   }
                 },
                 %{"list" => [%{"key" => "key_1"}, %{"key" => "key_2"}]}
               )
    end
  end

  describe "when schema does not match" do
    test "returns 'Values are not unique.' when value is a key" do
      assert "Values are not unique." ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     list: array(nil, callbacks: [uniq_by("key")])
                   }
                 },
                 %{"list" => [%{"key" => "key_1"}, %{"key" => "key_1"}]}
               )
    end

    test "returns 'Values are not unique.' when value is a function" do
      assert "Values are not unique." ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     list: array(nil, callbacks: [uniq_by(&Map.get(&1, "key"))])
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
                     list: array(nil, callbacks: [uniq_by(&Map.get(&1, "key"))])
                   }
                 },
                 %{}
               )
    end
  end
end
