defmodule Schemata.Schema do
  @derive Jason.Encoder

  defstruct "$schema": "http://json-schema.org/draft-04/schema#",
            type: "object",
            definitions: %{},
            dependencies: %{},
            properties: %{},
            required: [],
            additionalProperties: false
end

defimpl Jason.Encoder, for: Schemata.Schema do
  def encode(value, opts) do
    encode_value = Map.take(value, ~w($schema type properties additionalProperties dependencies)a)

    encode_value =
      if value.required && !Enum.empty?(value.required) do
        Map.put(encode_value, "required", value.required)
      else
        encode_value
      end

    encode_value =
      if value.definitions && !Enum.empty?(value.definitions) do
        Map.put(encode_value, "definitions", value.definitions)
      else
        encode_value
      end

    Jason.Encode.map(encode_value, opts)
  end
end
