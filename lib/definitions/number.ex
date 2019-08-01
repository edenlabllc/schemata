defmodule Schemata.Definitions.Number do
  defstruct [:description, :minimum, :exclusiveMinimum, :maximum, :exclusiveMaximum]

  def number(description \\ "") do
    %__MODULE__{description: description}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Number do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      %{"type" => "number", "description" => value.description}
      |> add_not_null_value(value, :minimum)
      |> add_not_null_value(value, :exclusiveMinimum)
      |> add_not_null_value(value, :maximum)
      |> add_not_null_value(value, :exclusiveMaximum)

    Jason.Encode.map(encode_value, opts)
  end
end
