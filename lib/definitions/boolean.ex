defmodule Schemata.Definitions.Boolean do
  defstruct []

  def boolean() do
    %__MODULE__{}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Boolean do
  def encode(_, opts) do
    encode_value = %{"type" => "boolean"}
    Jason.Encode.map(encode_value, opts)
  end
end
