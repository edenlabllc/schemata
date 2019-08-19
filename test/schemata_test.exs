defmodule SchemataTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  test "test 1" do
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
      |> JsonXema.new(inline: false)

    assert {:error,
            %JsonXema.ValidationError{
              message: nil,
              reason: %{properties: %{"test" => %{enum: ["a", "b"], value: "bla"}}}
            }} =
             JsonXema.validate(schema, %{
               "invalid" => "foo",
               "episode_id" => "c0ffc467-061e-49f0-b544-cc4634213876",
               "test" => "bla"
             })

    assert {:error,
            %JsonXema.ValidationError{
              message: nil,
              reason: %{required: ["episode_id"]}
            }} = JsonXema.validate(schema, %{})
  end

  test "test 2" do
    schema =
      %Schema{
        required: ["employee_request"],
        definitions: %{
          uuid: uuid(),
          gender: enum(["male", "female"]),
          name:
            regex("^(?!.*[ЫЪЭЁыъэё@%&$^#])[a-zA-ZА-ЯҐЇІЄа-яґїіє0-9№\\\"!\\^\\*)\\]\\[(._-].*$"),
          person_name: regex("^(?!.*[ЫЪЭЁыъэё@%&$^#])[А-ЯҐЇІЄа-яґїіє’\\'\\- ]+$"),
          phone:
            object(%{type: enum(["mobile"]), number: regex("^\\+38[0-9]{10}$")},
              required: [
                "type",
                "number"
              ]
            ),
          document:
            object(
              %{
                type: enum(["PASSPORT"]),
                number: string(minLength: 1),
                issued_by: string(minLength: 1),
                issued_at: date()
              },
              required: ["type", "number"]
            ),
          education:
            object(%{
              country: enum(["UKRAINE"]),
              city: ref("name"),
              institution_name: ref("name"),
              issued_date: date(),
              diploma_number: string(minLength: 1),
              degree: enum(["PHD"]),
              speciality: ref("name")
            })
        },
        properties: %{
          employee_request:
            object(%{
              legal_entity_id: ref("uuid"),
              division_id: ref("uuid"),
              employee_id: ref("uuid"),
              status: enum(["NEW"]),
              doctor:
                object(%{
                  educations: array(ref("education"))
                }),
              pharmacist:
                object(%{
                  educations: array(ref("education"))
                })
            })
        }
      }
      |> Jason.encode!()
      |> Jason.decode!()
      |> JsonXema.new(inline: false)

    assert {:error,
            %JsonXema.ValidationError{
              message: nil,
              reason: %{required: ["employee_request"]}
            }} = JsonXema.validate(schema, %{})

    assert {:error,
            %JsonXema.ValidationError{
              message: nil,
              reason: %{
                properties: %{
                  "employee_request" => %{
                    properties: %{
                      "invalid" => %{additionalProperties: false}
                    }
                  }
                }
              }
            }} =
             JsonXema.validate(schema, %{
               "employee_request" => %{
                 "invalid" => nil
               }
             })
  end
end
