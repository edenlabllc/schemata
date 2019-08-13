defmodule Schemata.Definitions.String do
  defstruct [:minLength, :maxLength]

  def string() do
    %__MODULE__{}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.String do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      %{"type" => "string"}
      |> add_not_null_value(value, :minLength)
      |> add_not_null_value(value, :maxLength)

    Jason.Encode.map(encode_value, opts)
  end
end
