defmodule Schemata.Validators.DateFromTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when schema matches" do
    test "returns :ok when equal is not enabled" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     date: date(callbacks: [date_from(Date.utc_today())])
                   }
                 },
                 %{"date" => Date.utc_today() |> Date.add(1) |> to_string()}
               )
    end

    test "returns :ok when equal is enabled" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     date: date(callbacks: [date_from(Date.utc_today(), true)])
                   }
                 },
                 %{"date" => to_string(Date.utc_today())}
               )
    end
  end

  describe "when schema does not match" do
    test "returns error when equal is disabled" do
      assert [
               {%{
                  description: "Date should be greater than" <> _,
                  params: %{actual: _, expected: _},
                  raw_description:
                    "Date should be greater than '%{expected}' but got '%{actual}'.",
                  rule: :date_from
                }, "$.date"}
             ] =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     date: date(callbacks: [date_from(Date.utc_today())])
                   }
                 },
                 %{"date" => Date.utc_today() |> Date.add(-1) |> to_string()}
               )
    end

    test "returns error when equal is enabled" do
      assert [
               {%{
                  description: "Date should be greater than or equal to" <> _,
                  params: %{actual: _, expected: _},
                  raw_description:
                    "Date should be greater than or equal to '%{expected}' but got '%{actual}'.",
                  rule: :date_from
                }, "$.date"}
             ] =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     date: date(callbacks: [date_from(Date.utc_today(), true)])
                   }
                 },
                 %{"date" => Date.utc_today() |> Date.add(-2) |> to_string()}
               )
    end
  end

  describe "when value is not set" do
    test "returns :ok" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     date: date(callbacks: [date_from(Date.utc_today())])
                   }
                 },
                 %{}
               )
    end
  end
end
