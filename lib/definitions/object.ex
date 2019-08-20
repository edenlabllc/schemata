defmodule Schemata.Definitions.Object do
  @moduledoc false

  @enforce_keys [:properties]

  defstruct type: "object",
            properties: nil,
            opts: [
              required: [],
              additionalProperties: false,
              dependencies: %{},
              minProperties: nil,
              maxProperties: nil,
              callbacks: []
            ]

  def object(properties) do
    %__MODULE__{properties: properties}
  end

  def object(properties, opts) do
    obj = %__MODULE__{properties: properties}
    %{obj | opts: Keyword.merge(obj.opts, opts)}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Object do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      value
      |> Map.take(~w(properties)a)
      |> Map.merge(%{type: "object"})
      |> add_not_null_value(value, :additionalProperties)
      |> add_not_null_value(value, :dependencies)
      |> add_not_null_value(value, :minProperties)
      |> add_not_null_value(value, :maxProperties)
      |> add_not_null_value(value, :required)

    Jason.Encode.map(encode_value, opts)
  end
end
