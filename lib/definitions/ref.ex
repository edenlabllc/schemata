defmodule Schemata.Definitions.Ref do
  @enforce_keys [:ref]

  defstruct [:ref]

  def ref(ref) do
    %__MODULE__{ref: ref}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Ref do
  def encode(value, opts) do
    Jason.Encode.map(%{"$ref" => "#/definitions/#{value.ref}"}, opts)
  end
end
