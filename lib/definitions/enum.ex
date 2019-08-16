defmodule Schemata.Definitions.Enum do
  @moduledoc false

  @derive {Jason.Encoder, only: [:type, :enum]}

  @enforce_keys [:enum]

  defstruct type: "string",
            enum: nil,
            callbacks: []

  def enum(values, callbacks \\ []) do
    %__MODULE__{enum: values, callbacks: callbacks}
  end
end
