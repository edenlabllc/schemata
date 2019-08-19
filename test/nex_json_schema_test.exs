defmodule NExJsonSchemaTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata
  alias NExJsonSchema.Validator

  describe "test create schema" do
    test "success" do
      schema =
        %Schema{
          required: [:episode_id],
          definitions: %{
            uuid: uuid()
          },
          properties: %{
            episode_id: ref("uuid"),
            encounter_id: ref("uuid"),
            test: enum(["a", "b"]),
            asserted_date_from: date(),
            asserted_date_end: date(),
            medication_code: string()
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "schema does not allow additional properties",
                   params: %{properties: %{"foo" => "bar"}},
                   raw_description: "schema does not allow additional properties",
                   rule: :schema
                 }, "$.foo"},
                {%{
                   description: "required property episode_id was not present",
                   params: %{property: "episode_id"},
                   raw_description: "required property %{property} was not present",
                   rule: :required
                 }, "$.episode_id"}
              ]} = Validator.validate(schema, %{"foo" => "bar"})
    end
  end

  describe "test validations" do
    test "allOf" do
      schema =
        %Schema{
          definitions: %{
            uuid: uuid()
          },
          properties: %{
            episode_id: %{
              allOf: [
                ref("uuid"),
                enum(["a", "b"])
              ]
            }
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description:
                     "expected all of the schemata to match, but the schemata at the following indexes did not: 0",
                   params: %{indexes: [0]},
                   raw_description:
                     "expected all of the schemata to match, but the schemata at the following indexes did not: %{indexes}",
                   rule: :schemata
                 }, "$.episode_id"}
              ]} = Validator.validate(schema, %{"episode_id" => "b"})
    end

    test "anyOf" do
      schema =
        %Schema{
          definitions: %{
            uuid: uuid()
          },
          properties: %{
            episode_id: %{
              anyOf: [
                ref("uuid"),
                enum(["a", "b"])
              ]
            }
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected any of the schemata to match but none did",
                   params: %{},
                   raw_description: "expected any of the schemata to match but none did",
                   rule: :schemata
                 }, "$.episode_id"}
              ]} = Validator.validate(schema, %{"episode_id" => "c"})
    end

    test "oneOf" do
      schema =
        %Schema{
          definitions: %{
            uuid: uuid()
          },
          properties: %{
            episode_id: %{
              oneOf: [
                ref("uuid"),
                enum(["a", "b"])
              ]
            }
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description:
                     "expected exactly one of the schemata to match, but none of them did",
                   params: %{},
                   raw_description:
                     "expected exactly one of the schemata to match, but none of them did",
                   rule: :schemata
                 }, "$.episode_id"}
              ]} = Validator.validate(schema, %{"episode_id" => "c"})
    end

    test "not" do
      schema =
        %Schema{
          properties: %{
            episode_id: %{
              not: string()
            }
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected schema not to match but it did",
                   params: %{},
                   raw_description: "expected schema not to match but it did",
                   rule: :schema
                 }, "$.episode_id"}
              ]} = Validator.validate(schema, %{"episode_id" => "c"})
    end

    test "type" do
      schema =
        %Schema{
          properties: %{
            episode_id: string()
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "type mismatch. Expected string but got integer",
                   params: %{actual: "integer", expected: "string"},
                   raw_description: "type mismatch. Expected %{expected} but got %{actual}",
                   rule: :cast
                 }, "$.episode_id"}
              ]} = Validator.validate(schema, %{"episode_id" => 1234})
    end

    test "properties" do
      schema =
        %Schema{
          properties: %{
            episode_id: string()
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "schema does not allow additional properties",
                   params: %{properties: %{"episode" => 1234}},
                   raw_description: "schema does not allow additional properties",
                   rule: :schema
                 }, "$.episode"}
              ]} = Validator.validate(schema, %{"episode" => 1234})
    end

    test "minProperties" do
      schema =
        %Schema{
          properties: %{
            episode: object(%{id: string()}, minProperties: 2)
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected a minimum of 2 properties but got 1",
                   params: %{actual: 1, min: 2},
                   raw_description: "expected a minimum of %{min} properties but got %{actual}",
                   rule: :length
                 }, "$.episode"}
              ]} = Validator.validate(schema, %{"episode" => %{"id" => "a"}})
    end

    test "maxProperties" do
      schema =
        %Schema{
          properties: %{
            episode: object(%{id: string(), name: string()}, maxProperties: 1)
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected a maximum of 1 properties but got 2",
                   params: %{actual: 2, max: 1},
                   raw_description: "expected a maximum of %{max} properties but got %{actual}",
                   rule: :length
                 }, "$.episode"}
              ]} = Validator.validate(schema, %{"episode" => %{"id" => "a", "name" => "b"}})
    end

    test "required" do
      schema =
        %Schema{
          required: ["episode_id"],
          properties: %{
            episode_id: string()
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "required property episode_id was not present",
                   params: %{property: "episode_id"},
                   raw_description: "required property %{property} was not present",
                   rule: :required
                 }, "$.episode_id"}
              ]} = Validator.validate(schema, %{})
    end

    test "property dependencies" do
      schema =
        %Schema{
          required: ["episode_id"],
          properties: %{
            episode_id: string(),
            encounter_id: string()
          },
          dependencies: %{
            episode_id: ["encounter_id"]
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description:
                     "property episode_id depends on encounter_id to be present but it was not",
                   params: %{dependency: "encounter_id", property: "episode_id"},
                   raw_description:
                     "property %{property} depends on %{dependency} to be present but it was not",
                   rule: :dependency
                 }, "$.episode_id"}
              ]} = Validator.validate(schema, %{"episode_id" => "a"})
    end

    test "schema dependencies" do
      schema =
        %Schema{
          properties: %{
            episode_id: string(),
            encounter_id: string()
          },
          dependencies: %{
            episode_id: %{
              properties: %{
                encounter_id: string()
              },
              required: ["encounter_id"]
            }
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "required property encounter_id was not present",
                   params: %{property: "encounter_id"},
                   raw_description: "required property %{property} was not present",
                   rule: :required
                 }, "$.encounter_id"}
              ]} = Validator.validate(schema, %{"episode_id" => "a"})

      assert :ok = Validator.validate(schema, %{"episode_id" => "a", "encounter_id" => "b"})
      assert :ok = Validator.validate(schema, %{"encounter_id" => "b"})
    end

    test "items" do
      schema =
        %Schema{
          properties: %{
            ids: array([string(), number()])
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "schema does not allow additional items",
                   params: %{},
                   raw_description: "schema does not allow additional items",
                   rule: :schema
                 }, "$.ids.[2]"}
              ]} = Validator.validate(schema, %{"ids" => ["123", 123, 1]})
    end

    test "minItems" do
      schema =
        %Schema{
          properties: %{
            ids: array(string(), minItems: 2)
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected a minimum of 2 items but got 1",
                   params: %{actual: 1, min: 2},
                   raw_description: "expected a minimum of %{min} items but got %{actual}",
                   rule: :length
                 }, "$.ids"}
              ]} = Validator.validate(schema, %{"ids" => ["123"]})
    end

    test "maxItems" do
      schema =
        %Schema{
          properties: %{
            ids: array(string(), maxItems: 1)
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected a maximum of 1 items but got 2",
                   params: %{actual: 2, max: 1},
                   raw_description: "expected a maximum of %{max} items but got %{actual}",
                   rule: :length
                 }, "$.ids"}
              ]} = Validator.validate(schema, %{"ids" => ["123", "1"]})
    end

    test "uniqueItems" do
      schema =
        %Schema{
          properties: %{
            ids: array(string(), uniqueItems: true)
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected items to be unique but they were not",
                   params: %{},
                   raw_description: "expected items to be unique but they were not",
                   rule: :unique
                 }, "$.ids"}
              ]} = Validator.validate(schema, %{"ids" => ["123", "123"]})
    end

    test "enum" do
      schema =
        %Schema{
          properties: %{
            type: enum(["a", "b"])
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "value is not allowed in enum",
                   params: %{values: ["a", "b"]},
                   raw_description: "value is not allowed in enum",
                   rule: :inclusion
                 }, "$.type"}
              ]} = Validator.validate(schema, %{"type" => "123"})
    end

    test "minimum" do
      schema =
        %Schema{
          properties: %{
            value: number(minimum: 5, exclusiveMinimum: false)
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected the value to be >= 5",
                   params: %{greater_than_or_equal_to: 5},
                   raw_description: "expected the value to be >= %{greater_than_or_equal_to}",
                   rule: :number
                 }, "$.value"}
              ]} = Validator.validate(schema, %{"value" => 2})
    end

    test "maximum" do
      schema =
        %Schema{
          properties: %{
            value: number(maximum: 5, exclusiveMaximum: false)
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected the value to be <= 5",
                   params: %{less_than_or_equal_to: 5},
                   raw_description: "expected the value to be <= %{less_than_or_equal_to}",
                   rule: :number
                 }, "$.value"}
              ]} = Validator.validate(schema, %{"value" => 10})
    end

    test "minLength" do
      schema =
        %Schema{
          properties: %{
            value: string(minLength: 5)
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected value to have a minimum length of 5 but was 3",
                   params: %{actual: 3, min: 5},
                   raw_description:
                     "expected value to have a minimum length of %{min} but was %{actual}",
                   rule: :length
                 }, "$.value"}
              ]} = Validator.validate(schema, %{"value" => "foo"})
    end

    test "maxLength" do
      schema =
        %Schema{
          properties: %{
            value: string(maxLength: 5)
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected value to have a maximum length of 5 but was 6",
                   params: %{actual: 6, max: 5},
                   raw_description:
                     "expected value to have a maximum length of %{max} but was %{actual}",
                   rule: :length
                 }, "$.value"}
              ]} = Validator.validate(schema, %{"value" => "foobar"})
    end

    test "pattern" do
      schema =
        %Schema{
          properties: %{
            value: regex("~r/[abc]{2}/")
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "string does not match pattern \"~r/[abc]{2}/\"",
                   params: %{pattern: "~r/[abc]{2}/"},
                   raw_description: "string does not match pattern \"%{pattern}\"",
                   rule: :format
                 }, "$.value"}
              ]} = Validator.validate(schema, %{"value" => "foo"})
    end

    test "format date" do
      schema =
        %Schema{
          properties: %{
            value: date()
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected \"invalid date\" to be a valid ISO 8601 date",
                   params: %{
                     actual: "invalid date",
                     pattern:
                       "^([\\+-]?\\d{4}(?!\\d{2}\\b))((-?)((0[1-9]|1[0-2])(\\3([12]\\d|0[1-9]|3[01]))?|W([0-4]\\d|5[0-2])(-?[1-7])?|(00[1-9]|0[1-9]\\d|[12]\\d{2}|3([0-5]\\d|6[1-6])))?)?$"
                   },
                   raw_description: "expected \"%{actual}\" to be a valid ISO 8601 date",
                   rule: :date
                 }, "$.value"}
              ]} = Validator.validate(schema, %{"value" => "invalid date"})
    end

    test "format datetime" do
      schema =
        %Schema{
          properties: %{
            value: datetime()
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected \"invalid datetime\" to be a valid ISO 8601 date-time",
                   params: %{
                     actual: "invalid datetime",
                     pattern:
                       "^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\\.[0-9]+)?(Z|[+-](?:2[0-3]|[01][0-9]):[0-5][0-9])?$"
                   },
                   raw_description: "expected \"%{actual}\" to be a valid ISO 8601 date-time",
                   rule: :datetime
                 }, "$.value"}
              ]} = Validator.validate(schema, %{"value" => "invalid datetime"})
    end

    test "format hostname" do
      schema =
        %Schema{
          properties: %{
            value: hostname()
          },
          additionalProperties: false
        }
        |> Jason.encode!()
        |> Jason.decode!()
        |> NExJsonSchema.Schema.resolve()

      assert {:error,
              [
                {%{
                   description: "expected \"invalid hostname\" to be a host name",
                   params: %{
                     actual: "invalid hostname",
                     pattern:
                       "^((?=[a-z0-9-]{1,63}\\.)(xn--)?[a-z0-9]+(-[a-z0-9]+)*\\.)+[a-z]{2,63}$"
                   },
                   raw_description: "expected \"%{actual}\" to be a host name",
                   rule: :format
                 }, "$.value"}
              ]} = Validator.validate(schema, %{"value" => "invalid hostname"})
    end
  end
end
