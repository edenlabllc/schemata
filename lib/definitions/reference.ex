defmodule Schemata.Definitions.Reference do
  @enforce_keys [:ref]

  defstruct [:ref]

  def ref(ref) do
    %__MODULE__{ref: ref}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Reference do
  def encode(value, opts) do
    Jason.Encode.map(%{"$ref" => "#/definitions/#{value.ref}"}, opts)
  end
end
