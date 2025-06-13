defmodule Schemata.Validators.PersonNameTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when schema matches" do
    test "returns :ok" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     first_name: string(callbacks: [person_name()])
                   }
                 },
                 %{"first_name" => "Анна-Марія"}
               )
    end
  end

  describe "when there is letter from other alphabet" do
    test "returns {:error, [...]} with russian letter" do
      assert {:error,
              [
                {%{
                   description:
                     ~S(String does not match pattern '^[А-ЩЬЮЯҐЄІЇа-щьюяґєії\s\.\-/']+$'),
                   params: %{pattern: ~S(^[А-ЩЬЮЯҐЄІЇа-щьюяґєії\s\.\-/']+$), value: "Анна-Марыя"},
                   raw_description: "String does not match pattern '%{pattern}'",
                   rule: :regexs
                 }, "$.first_name"}
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     first_name: string(callbacks: [person_name()])
                   }
                 },
                 %{"first_name" => "Анна-Марыя"}
               )
    end

    test "returns {:error, [...]} with english letter" do
      assert {:error,
              [
                {%{
                   description:
                     ~S(String does not match pattern '^[А-ЩЬЮЯҐЄІЇа-щьюяґєії\s\.\-/']+$'),
                   params: %{pattern: ~S(^[А-ЩЬЮЯҐЄІЇа-щьюяґєії\s\.\-/']+$), value: "Анна-МаріR"},
                   raw_description: "String does not match pattern '%{pattern}'",
                   rule: :regexs
                 }, "$.first_name"}
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     first_name: string(callbacks: [person_name()])
                   }
                 },
                 %{"first_name" => "Анна-МаріR"}
               )
    end
  end

  describe "when there are special characters twice in a row" do
    test "returns {:error, [...]}" do
      assert {:error,
              [
                {%{
                   description: ~S(String matches pattern '[\s\.\-/']{2,}' but it should not),
                   params: %{pattern: ~S([\s\.\-/']{2,}), value: "Анна--Марія"},
                   raw_description: "String matches pattern '%{pattern}' but it should not",
                   rule: :regexs
                 }, "$.first_name"}
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     first_name: string(callbacks: [person_name()])
                   }
                 },
                 %{"first_name" => "Анна--Марія"}
               )
    end
  end

  describe "when first character is special symbol" do
    test "returns {:error, [...]}" do
      assert {:error,
              [
                {%{
                   description: "String does not match pattern '^[А-ЩЬЮЯҐЄІЇа-щьюяґєії]'",
                   params: %{pattern: "^[А-ЩЬЮЯҐЄІЇа-щьюяґєії]", value: ".Анна-Марія"},
                   raw_description: "String does not match pattern '%{pattern}'",
                   rule: :regexs
                 }, "$.first_name"}
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     first_name: string(callbacks: [person_name()])
                   }
                 },
                 %{"first_name" => ".Анна-Марія"}
               )
    end
  end

  describe "when last character is space" do
    test "returns {:error, [...]}" do
      assert {:error,
              [
                {%{
                   description: ~S(String matches pattern '[\s\-/']$' but it should not),
                   params: %{pattern: ~S([\s\-/']$), value: "Анна-Марія "},
                   raw_description: "String matches pattern '%{pattern}' but it should not",
                   rule: :regexs
                 }, "$.first_name"}
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     first_name: string(callbacks: [person_name()])
                   }
                 },
                 %{"first_name" => "Анна-Марія "}
               )
    end
  end

  describe "when there is '@' character" do
    test "returns {:error, [...]}" do
      assert {:error,
              [
                {%{
                   description:
                     ~S(String does not match pattern '^[А-ЩЬЮЯҐЄІЇа-щьюяґєії\s\.\-/']+$'),
                   params: %{pattern: ~S(^[А-ЩЬЮЯҐЄІЇа-щьюяґєії\s\.\-/']+$), value: "Анна-М@рія"},
                   raw_description: "String does not match pattern '%{pattern}'",
                   rule: :regexs
                 }, "$.first_name"}
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     first_name: string(callbacks: [person_name()])
                   }
                 },
                 %{"first_name" => "Анна-М@рія"}
               )
    end
  end

  describe "when value is not set" do
    test "returns :ok" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     first_name: string(callbacks: [person_name()])
                   }
                 },
                 %{}
               )
    end
  end
end
