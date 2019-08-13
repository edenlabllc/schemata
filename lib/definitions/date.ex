defmodule Schemata.Definitions.Date do
  defstruct []

  def date(), do: %__MODULE__{}
end

defimpl Jason.Encoder, for: Schemata.Definitions.Date do
  def encode(_, opts) do
    Jason.Encode.map(
      %{"type" => "string", "format" => "date"},
      opts
    )
  end
end
