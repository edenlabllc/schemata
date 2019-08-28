defmodule Schemata.Definitions.UUID do
  @moduledoc false

  defstruct type: "string",
            pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
            opts: [callbacks: [], null: false]

  def uuid(), do: %__MODULE__{}
  def uuid(opts), do: %__MODULE__{opts: opts}
end

defimpl Jason.Encoder, for: Schemata.Definitions.UUID do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      value
      |> Map.take(~w(pattern)a)
      |> add_type(value, "string")

    Jason.Encode.map(encode_value, opts)
  end
end
