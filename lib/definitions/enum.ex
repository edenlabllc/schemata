defmodule Schemata.Definitions.Enum do
  @derive Jason.Encoder

  @enforce_keys [:enum]

  defstruct type: "string",
            enum: nil

  def enum(values) do
    %__MODULE__{enum: values}
  end
end
