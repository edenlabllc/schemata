defmodule Schemata.Definitions.Regex do
  @moduledoc false

  @enforce_keys [:pattern]

  defstruct type: "string",
            pattern: nil,
            opts: [callbacks: [], null: false]

  def regex(pattern), do: %__MODULE__{pattern: pattern}
  def regex(pattern, opts), do: %__MODULE__{pattern: pattern, opts: opts}
end

defimpl Jason.Encoder, for: Schemata.Definitions.Regex do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      value
      |> Map.take(~w(pattern)a)
      |> add_type(value, "string")

    Jason.Encode.map(encode_value, opts)
  end
end
