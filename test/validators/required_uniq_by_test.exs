defmodule Schemata.Validators.RequiredUniqByTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when schema matches" do
    test "returns :ok when value is a key" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     list: array(nil, callbacks: [required_uniq_by({"key", "key_1"})])
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
                     list:
                       array(nil, callbacks: [required_uniq_by(&(Map.get(&1, "key") == "key_1"))])
                   }
                 },
                 %{"list" => [%{"key" => "key_1"}, %{"key" => "key_2"}]}
               )
    end
  end

  describe "when schema does not match" do
    test "returns 'Only one and unqiue field is required.' when value is a key" do
      assert "Only one and unqiue field is required." ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     list: array(nil, callbacks: [required_uniq_by({"key", "key_1"})])
                   }
                 },
                 %{"list" => [%{"key" => "key_1"}, %{"key" => "key_1"}]}
               )
    end

    test "returns 'Only one and unqiue field is required.' when value is a function" do
      assert "Only one and unqiue field is required." ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     list:
                       array(nil, callbacks: [required_uniq_by(&(Map.get(&1, "key") == "key_1"))])
                   }
                 },
                 %{"list" => [%{"key" => "key_1"}, %{"key" => "key_1"}]}
               )
    end
  end
end
