defmodule Schemata.Definitions.Boolean do
  @moduledoc false

  defstruct opts: [callbacks: []]

  def boolean() do
    %__MODULE__{}
  end

  def boolean(opts) do
    %__MODULE__{opts: opts}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Boolean do
  def encode(_, opts) do
    encode_value = %{"type" => "boolean"}
    Jason.Encode.map(encode_value, opts)
  end
end
