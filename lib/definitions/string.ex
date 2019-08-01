defmodule Schemata.Definitions.String do
  defstruct [:description, :minLength, :maxLength]

  def string(description \\ "") do
    %__MODULE__{description: description}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.String do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      %{"type" => "string", "description" => value.description}
      |> add_not_null_value(value, :minLength)
      |> add_not_null_value(value, :maxLength)

    Jason.Encode.map(encode_value, opts)
  end
end
