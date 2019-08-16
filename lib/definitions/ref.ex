defmodule Schemata.Definitions.Ref do
  @moduledoc false

  @enforce_keys [:ref]

  defstruct [:ref, :callbacks]

  def ref(ref, callbacks \\ []) do
    %__MODULE__{ref: ref, callbacks: callbacks}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Ref do
  def encode(value, opts) do
    Jason.Encode.map(%{"$ref" => "#/definitions/#{value.ref}"}, opts)
  end
end
