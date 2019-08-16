defmodule Schemata.Definitions.Boolean do
  @moduledoc false

  defstruct callbacks: []

  def boolean(callbacks \\ []) do
    %__MODULE__{callbacks: callbacks}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Boolean do
  def encode(_, opts) do
    encode_value = %{"type" => "boolean"}
    Jason.Encode.map(encode_value, opts)
  end
end
