defmodule Schemata.Definitions.Enum do
  @derive Jason.Encoder

  @enforce_keys [:enum]

  defstruct type: "string",
            description: "",
            enum: nil

  def enum(values, description \\ "") do
    %__MODULE__{enum: values, description: description}
  end
end
