defmodule Schemata.Definitions.Hostname do
  defstruct []

  def hostname(), do: %__MODULE__{}
end

defimpl Jason.Encoder, for: Schemata.Definitions.Hostname do
  def encode(_, opts) do
    Jason.Encode.map(
      %{"type" => "string", "format" => "hostname"},
      opts
    )
  end
end
