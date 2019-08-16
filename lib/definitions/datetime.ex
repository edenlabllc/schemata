defmodule Schemata.Definitions.Datetime do
  @moduledoc false

  defstruct callbacks: []

  def datetime(callbacks \\ []), do: %__MODULE__{callbacks: callbacks}
end

defimpl Jason.Encoder, for: Schemata.Definitions.Datetime do
  def encode(_, opts) do
    Jason.Encode.map(
      %{"type" => "string", "format" => "date-time"},
      opts
    )
  end
end
