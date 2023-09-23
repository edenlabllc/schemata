defmodule Schemata.Validators.DateToTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when schema matches" do
    test "returns :ok" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     today: date(callbacks: [date_to(Date.utc_today())])
                   }
                 },
                 %{"today" => to_string(Date.utc_today())}
               )
    end
  end

  describe "when does not match" do
    test "returns 'Date should be less than or equal to '2023-09-23''" do
      assert "Date should be less than or equal to '2023-09-23'" ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     today: date(callbacks: [date_to(Date.utc_today())])
                   }
                 },
                 %{"today" => Date.utc_today() |> Date.add(1) |> to_string()}
               )
    end
  end
end
