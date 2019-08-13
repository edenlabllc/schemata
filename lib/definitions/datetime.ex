defmodule Schemata.Definitions.Datetime do
  defstruct []

  def datetime(), do: %__MODULE__{}
end

defimpl Jason.Encoder, for: Schemata.Definitions.Datetime do
  def encode(_, opts) do
    Jason.Encode.map(
      %{"type" => "string", "format" => "date-time"},
      opts
    )
  end
end
