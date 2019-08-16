defmodule Schemata.Definitions.Array do
  @moduledoc false

  @enforce_keys [:items]

  defstruct type: "array",
            items: nil,
            additionalItems: false,
            minItems: 1,
            maxItems: nil,
            uniqueItems: false,
            callbacks: []

  def array(items, callbacks \\ []) do
    %__MODULE__{items: items, callbacks: callbacks}
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
