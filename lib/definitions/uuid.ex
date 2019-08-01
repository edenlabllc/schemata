defmodule Schemata.Definitions.UUID do
  @derive Jason.Encoder

  defstruct type: "string",
            pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"

  def uuid, do: %__MODULE__{}
end
