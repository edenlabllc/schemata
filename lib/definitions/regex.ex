defmodule Schemata.Definitions.Regex do
  @moduledoc false

  @derive {Jason.Encoder, only: [:type, :pattern]}

  @enforce_keys [:pattern]

  defstruct type: "string",
            pattern: nil,
            callbacks: []

  def regex(pattern, callbacks \\ []), do: %__MODULE__{pattern: pattern, callbacks: callbacks}
end
