defmodule Schemata.Definitions.Regex do
  @moduledoc false

  @derive {Jason.Encoder, only: [:type, :pattern]}

  @enforce_keys [:pattern]

  defstruct type: "string",
            pattern: nil,
            opts: [callbacks: []]

  def regex(pattern), do: %__MODULE__{pattern: pattern}
  def regex(pattern, opts), do: %__MODULE__{pattern: pattern, opts: opts}
end
