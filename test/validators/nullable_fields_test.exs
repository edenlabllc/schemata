defmodule NullableFieldsTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata
  alias NExJsonSchema.Validator

  describe "test nullable fields" do
    test "success" do
      schema =
        %Schema{
          properties: %{
            array: array(string(), null: true),
            boolean: boolean(null: true),
            date: date(null: true),
            datetime: datetime(null: true),
            hostname: hostname(null: true),
            number: number(null: true),
            object: object(%{}, null: true),
            regex: regex("/[abc]{2}/", null: true),
            string: string(null: true),
            time: time(null: true),
            uuid: uuid(null: true),
            foo:
              %{}
              |> object()
              |> null()
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert :ok =
               Validator.validate(schema, %{
                 "array" => nil,
                 "boolean" => nil,
                 "date" => nil,
                 "datetime" => nil,
                 "hostname" => nil,
                 "number" => nil,
                 "object" => nil,
                 "regex" => nil,
                 "string" => nil,
                 "time" => nil,
                 "uuid" => nil,
                 "foo" => nil
               })
    end
  end
end
