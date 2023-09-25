defmodule Schemata.Validators.DateToTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when schema matches" do
    test "returns :ok when equal is not enabled" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     date: date(callbacks: [date_to(Date.utc_today())])
                   }
                 },
                 %{"date" => Date.utc_today() |> Date.add(-1) |> to_string()}
               )
    end

    test "returns :ok when equal is enabled" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     date: date(callbacks: [date_to(Date.utc_today(), true)])
                   }
                 },
                 %{"date" => to_string(Date.utc_today())}
               )
    end
  end

  describe "when does not match" do
    test "returns 'Date should be less than or equal to ...'" do
      assert "Date should be less than or equal to" <> _ =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     date: date(callbacks: [date_to(Date.utc_today())])
                   }
                 },
                 %{"date" => Date.utc_today() |> Date.add(1) |> to_string()}
               )
    end
  end

  describe "when value is not set" do
    test "returns :ok" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     date: date(callbacks: [date_to(Date.utc_today())])
                   }
                 },
                 %{}
               )
    end
  end
end
