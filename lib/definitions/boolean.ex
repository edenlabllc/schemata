defmodule Schemata.Definitions.Boolean do
  @moduledoc false

  defstruct opts: [callbacks: [], null: false]

  def boolean() do
    %__MODULE__{}
  end

  def boolean(opts) do
    %__MODULE__{opts: opts}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Boolean do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value = add_type(%{}, value, "boolean")
    Jason.Encode.map(encode_value, opts)
  end
end
