defmodule Schemata.Definitions.Object do
  @moduledoc false

  @enforce_keys [:properties]

  defstruct type: "object",
            properties: nil,
            required: [],
            additionalProperties: false,
            dependencies: %{},
            minProperties: nil,
            maxProperties: nil,
            callbacks: []

  def object(properties, required \\ [], callbacks \\ []) do
    %__MODULE__{properties: properties, required: required, callbacks: callbacks}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Object do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      value
      |> Map.take(~w(properties additionalProperties)a)
      |> Map.merge(%{type: "object"})
      |> add_not_null_value(value, :dependencies)
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
