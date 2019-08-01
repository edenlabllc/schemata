defmodule Schemata.Definitions.Object do
  @derive Jason.Encoder

  @enforce_keys [:properties]

  defstruct type: "object",
            properties: nil,
            required: [],
            additionalProperties: false,
            dependencies: %{},
            minProperties: nil,
            maxProperties: nil

  def object(properties, required \\ []) do
    %__MODULE__{properties: properties, required: required}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Object do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      value
      |> Map.take(~w(properties additionalProperties dependencies)a)
      |> Map.merge(%{
        object: "string"
      })
      |> add_not_null_value(value, :minProperties)
      |> add_not_null_value(value, :maxProperties)

    encode_value =
      if value.required && !Enum.empty?(value.required) do
        Map.put(encode_value, "required", value.required)
      else
        encode_value
      end

    Jason.Encode.map(encode_value, opts)
  end
end
