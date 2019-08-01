defmodule Schemata.Definitions.Regex do
  @derive Jason.Encoder

  @enforce_keys [:pattern]

  defstruct type: "string",
            pattern: nil

  def regex(pattern), do: %__MODULE__{pattern: pattern}
end
