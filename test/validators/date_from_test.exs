defmodule Schemata.Validators.DateFromTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when schema matches" do
    test "returns :ok when equal is not enabled" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     today: date(callbacks: [date_from(Date.utc_today())])
                   }
                 },
                 %{"today" => Date.utc_today() |> Date.add(1) |> to_string()}
               )
    end

    test "returns :ok when equal is enabled" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     today: date(callbacks: [date_from(Date.utc_today(), true)])
                   }
                 },
                 %{"today" => to_string(Date.utc_today())}
               )
    end
  end

  describe "when schema does not match" do
    test "returns 'Date should be greater than or equal to '2023-09-23''" do
      assert "Date should be greater than or equal to '2023-09-23'" ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     today: date(callbacks: [date_from(Date.utc_today())])
                   }
                 },
                 %{"today" => Date.utc_today() |> Date.add(-1) |> to_string()}
               )
    end
  end
end
