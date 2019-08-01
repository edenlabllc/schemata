defmodule Schemata.Definitions.Array do
  @derive Jason.Encoder

  @enforce_keys [:items]

  defstruct type: "array",
            items: nil,
            additionalItems: false,
            minItems: 1,
            maxItems: nil,
            uniqueItems: false

  def array(items) do
    %__MODULE__{items: items}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Array do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      value
      |> Map.take(~w(type items additionalItems uniqueItems)a)
      |> add_not_null_value(value, :minItems)
      |> add_not_null_value(value, :maxItems)

    Jason.Encode.map(encode_value, opts)
  end
end
