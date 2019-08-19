defmodule Schemata.Definitions.Ref do
  @moduledoc false

  @enforce_keys [:ref]

  defstruct [:ref, opts: [callbacks: []]]

  def ref(ref) do
    %__MODULE__{ref: ref}
  end

  def ref(ref, opts) do
    %__MODULE__{ref: ref, opts: opts}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Ref do
  def encode(value, opts) do
    Jason.Encode.map(%{"$ref" => "#/definitions/#{value.ref}"}, opts)
  end
end
