defmodule Schemata.Definitions.Enum do
  @moduledoc false

  @derive {Jason.Encoder, only: [:type, :enum]}

  @enforce_keys [:enum]

  defstruct type: "string",
            enum: nil,
            opts: [callbacks: []]

  def enum(values) do
    %__MODULE__{enum: values}
  end

  def enum(values, opts) do
    %__MODULE__{enum: values, opts: opts}
  end
end
