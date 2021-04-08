defmodule Schemata.Definitions.Enum do
  @moduledoc false

  @derive {Jason.Encoder, only: [:type, :enum]}

  @enforce_keys [:enum]

  defstruct type: "string",
            enum: nil,
            opts: [
              callbacks: [],
              null: false
            ]

  def enum(values) do
    %__MODULE__{enum: values}
  end

  def enum(values, opts) do
    opts = Keyword.merge([callbacks: []], opts)
    nullable? = Keyword.get(opts, :null)
    type = if nullable?, do: ["string", "null"], else: "string"
    values = if nullable?, do: values ++ [nil], else: values
    %__MODULE__{enum: values, opts: opts, type: type}
  end
end
