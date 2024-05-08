defmodule Schemata.Validators.ValidateIfTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "when value matches regex" do
    test "returns :ok" do
      assert :ok =
               assert(
                 :ok =
                   SchemaValidator.validate(
                     %Schema{
                       properties: %{
                         property:
                           object(
                             %{
                               type: string(null: true),
                               number: string(null: true)
                             },
                             callbacks: [
                               validate_if(
                                 %{
                                   "BIRTH_CERTIFICATE" =>
                                     ~r/^((?![ЫЪЭЁыъэё@%&$^#`~:,.*|}{?!])[A-ZА-ЯҐЇІЄ0-9№\\\/()-]){2,25}$/u
                                 },
                                 base_field: "type",
                                 filter_field: "number"
                               )
                             ]
                           )
                       }
                     },
                     %{
                       "property" => %{
                         "type" => "BIRTH_CERTIFICATE",
                         "number" => "1233123412Я"
                       }
                     }
                   )
               )
    end
  end

  describe "when value matches string" do
    test "returns :ok" do
      assert :ok =
               assert(
                 :ok =
                   SchemaValidator.validate(
                     %Schema{
                       properties: %{
                         property:
                           object(
                             %{
                               type: string(null: true),
                               number: string(null: true)
                             },
                             callbacks: [
                               validate_if(
                                 %{
                                   "BIRTH_CERTIFICATE" => "1234567890"
                                 },
                                 base_field: "type",
                                 filter_field: "number"
                               )
                             ]
                           )
                       }
                     },
                     %{
                       "property" => %{
                         "type" => "BIRTH_CERTIFICATE",
                         "number" => "1234567890"
                       }
                     }
                   )
               )
    end
  end

  describe "when value validated by function" do
    test "returns :ok" do
      assert :ok =
               assert(
                 :ok =
                   SchemaValidator.validate(
                     %Schema{
                       properties: %{
                         property:
                           object(
                             %{
                               type: string(null: true),
                               number: string(null: true)
                             },
                             callbacks: [
                               validate_if(
                                 %{
                                   "BIRTH_CERTIFICATE" => &String.starts_with?(&1, "123")
                                 },
                                 base_field: "type",
                                 filter_field: "number"
                               )
                             ]
                           )
                       }
                     },
                     %{
                       "property" => %{
                         "type" => "BIRTH_CERTIFICATE",
                         "number" => "1234567890"
                       }
                     }
                   )
               )
    end
  end

  describe "when value lower than filter value" do
    test "returns :ok" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     property:
                       object(
                         %{
                           type: string(null: true),
                           number: string(null: true)
                         },
                         callbacks: [
                           validate_if(
                             %{
                               "BIRTH_CERTIFICATE" => {:lt, 100_000}
                             },
                             base_field: "type",
                             filter_field: "number"
                           )
                         ]
                       )
                   }
                 },
                 %{
                   "property" => %{
                     "type" => "BIRTH_CERTIFICATE",
                     "number" => "123"
                   }
                 }
               )
    end
  end

  describe "when value greater than filter value" do
    test "returns :ok" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     property:
                       object(
                         %{
                           type: string(null: true),
                           number: string(null: true)
                         },
                         callbacks: [
                           validate_if(
                             %{
                               "BIRTH_CERTIFICATE" => {:gt, 100_000}
                             },
                             base_field: "type",
                             filter_field: "number"
                           )
                         ]
                       )
                   }
                 },
                 %{
                   "property" => %{
                     "type" => "BIRTH_CERTIFICATE",
                     "number" => "1234567890"
                   }
                 }
               )
    end
  end

  describe "when value lower then or equal to filter value" do
    test "returns :ok" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     property:
                       object(
                         %{
                           type: string(null: true),
                           number: string(null: true)
                         },
                         callbacks: [
                           validate_if(
                             %{
                               "BIRTH_CERTIFICATE" => {:lte, 100_000}
                             },
                             base_field: "type",
                             filter_field: "number"
                           )
                         ]
                       )
                   }
                 },
                 %{
                   "property" => %{
                     "type" => "BIRTH_CERTIFICATE",
                     "number" => "99000"
                   }
                 }
               )
    end
  end

  describe "when value greater then or equal to filter value" do
    test "returns :ok" do
      assert :ok =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     property:
                       object(
                         %{
                           type: string(null: true),
                           number: string(null: true)
                         },
                         callbacks: [
                           validate_if(
                             %{
                               "BIRTH_CERTIFICATE" => {:gte, 100_000}
                             },
                             base_field: "type",
                             filter_field: "number"
                           )
                         ]
                       )
                   }
                 },
                 %{
                   "property" => %{
                     "type" => "BIRTH_CERTIFICATE",
                     "number" => "100001"
                   }
                 }
               )
    end

    test "returns {:error, <error_message>}" do
      assert {:error,
              [
                {%{
                   description: "value is less than 100000",
                   params: %{
                     filter: {:gte, 100_000},
                     value: 99999.0
                   },
                   raw_description: "value is less than 100000",
                   rule: :validate_if
                 }, "$.property.number"}
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     property:
                       object(
                         %{
                           type: string(null: true),
                           number: string(null: true)
                         },
                         callbacks: [
                           validate_if(
                             %{
                               "BIRTH_CERTIFICATE" => {:gte, 100_000}
                             },
                             base_field: "type",
                             filter_field: "number",
                             message: "value is less than 100000"
                           )
                         ]
                       )
                   }
                 },
                 %{
                   "property" => %{
                     "type" => "BIRTH_CERTIFICATE",
                     "number" => "99999"
                   }
                 }
               )
    end
  end

  describe "when value does not match regex" do
    test "returns {:error, <error info>}" do
      assert {:error,
              [
                {%{
                   description: "string does not match pattern",
                   params: %{
                     filter: "^((?![ЫЪЭЁыъэё@%&$^#`~:,.*|}{?!])[A-ZА-ЯҐЇІЄ0-9№\\\\/()-]){2,25}$",
                     value: "!231cv1233123412"
                   },
                   raw_description: "string does not match pattern",
                   rule: :validate_if
                 }, "$.property.number"}
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     property:
                       object(
                         %{
                           type: string(null: true),
                           number: string(null: true)
                         },
                         callbacks: [
                           validate_if(
                             %{
                               "BIRTH_CERTIFICATE" =>
                                 ~r/^((?![ЫЪЭЁыъэё@%&$^#`~:,.*|}{?!])[A-ZА-ЯҐЇІЄ0-9№\\\/()-]){2,25}$/u
                             },
                             base_field: "type",
                             filter_field: "number"
                           )
                         ]
                       )
                   }
                 },
                 %{
                   "property" => %{
                     "type" => "BIRTH_CERTIFICATE",
                     "number" => "!231cv1233123412"
                   }
                 }
               )
    end
  end

  describe "when multiple values do not match regex" do
    test "returns {:error, <error info>}" do
      assert {:error,
              [
                {
                  %{
                    description:
                      "string does not match pattern \"^((?![ЫЪЭЁыъэё@%&$^#`~:,.*|}{?!])[A-ZА-ЯҐЇІЄ0-9№\\\\/()-]){2,25}$\"",
                    params: %{
                      filter: "^((?![ЫЪЭЁыъэё@%&$^#`~:,.*|}{?!])[A-ZА-ЯҐЇІЄ0-9№\\\\/()-]){2,25}$",
                      value: "!WRONG"
                    },
                    raw_description: "string does not match pattern \"%{pattern}\"",
                    rule: :validate_if
                  },
                  "$.documents.[0].number"
                },
                {
                  %{
                    description:
                      "string does not match pattern \"^((?![ЫЪЭЁ])([А-ЯҐЇІЄ])){2}[0-9]{6}$\"",
                    params: %{
                      filter: "^((?![ЫЪЭЁ])([А-ЯҐЇІЄ])){2}[0-9]{6}$",
                      value: "!ABC"
                    },
                    raw_description: "string does not match pattern \"%{pattern}\"",
                    rule: :validate_if
                  },
                  "$.documents.[1].number"
                }
              ]} =
               SchemaValidator.validate(
                 %Schema{
                   definitions: %{
                     document:
                       object(%{
                         type: string(null: true),
                         number: string(null: true)
                       })
                   },
                   properties: %{
                     documents:
                       array(ref("document"),
                         callbacks: [
                           validate_if(
                             %{
                               "PASSPORT" => ~r/^((?![ЫЪЭЁ])([А-ЯҐЇІЄ])){2}[0-9]{6}$/u,
                               "NATIONAL_ID" => ~r/^[0-9]{9}$/u,
                               "BIRTH_CERTIFICATE" =>
                                 ~r/^((?![ЫЪЭЁыъэё@%&$^#`~:,.*|}{?!])[A-ZА-ЯҐЇІЄ0-9№\\\/()-]){2,25}$/u,
                               "COMPLEMENTARY_PROTECTION_CERTIFICATE" =>
                                 ~r/^((?![ЫЪЭЁ])([А-ЯҐЇІЄ])){2}[0-9]{6}$/u,
                               "REFUGEE_CERTIFICATE" => ~r/^((?![ЫЪЭЁ])([А-ЯҐЇІЄ])){2}[0-9]{6}$/u,
                               "TEMPORARY_CERTIFICATE" =>
                                 ~r/^(((?![ЫЪЭЁ])([А-ЯҐЇІЄ])){2}[0-9]{4,6}|[0-9]{9}|((?![ЫЪЭЁ])([А-ЯҐЇІЄ])){2}[0-9]{5}\\\/[0-9]{5})$/u,
                               "TEMPORARY_PASSPORT" =>
                                 ~r/^((?![ЫЪЭЁыъэё@%&$^#`~:,.*|}{?!])[A-ZА-ЯҐЇІЄ0-9№\\\/()-]){2,25}$/u
                             },
                             base_field: "type",
                             filter_field: "number",
                             message: fn rule, field_value, filter_field, filter ->
                               {
                                 %{
                                   description: "string does not match pattern \"#{filter}\"",
                                   params: %{
                                     value: field_value,
                                     filter: filter
                                   },
                                   raw_description:
                                     "string does not match pattern \"%{pattern}\"",
                                   rule: rule
                                 },
                                 filter_field
                               }
                             end
                           )
                         ]
                       )
                   }
                 },
                 %{
                   "documents" => [
                     %{
                       "type" => "BIRTH_CERTIFICATE",
                       "number" => "!WRONG"
                     },
                     %{
                       "type" => "COMPLEMENTARY_PROTECTION_CERTIFICATE",
                       "number" => "!ABC"
                     }
                   ]
                 }
               )
    end
  end

  describe "with custom error message function" do
    test "returns {:error, <custom message>}" do
      assert {:error,
              "value 99999.0 by path $.property.number is less than 100 000. Rule: :gte_100_000"} =
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     property:
                       object(
                         %{
                           type: string(null: true),
                           number: string(null: true)
                         },
                         callbacks: [
                           validate_if(
                             %{
                               "BIRTH_CERTIFICATE" => {:gte, 100_000}
                             },
                             base_field: "type",
                             filter_field: "number",
                             rule: :gte_100_000,
                             message: fn rule, value, path, _filter ->
                               "value #{value} by path #{path} is less than 100 000. Rule: #{inspect(rule)}"
                             end
                           )
                         ]
                       )
                   }
                 },
                 %{
                   "property" => %{
                     "type" => "BIRTH_CERTIFICATE",
                     "number" => "99999"
                   }
                 }
               )
    end
  end
end
