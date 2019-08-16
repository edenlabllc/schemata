defmodule Schemata.Definitions.UUID do
  @moduledoc false

  @derive {Jason.Encoder, [only: [:type, :pattern]]}

  defstruct type: "string",
            pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
            callbacks: []

  def uuid(callbacks \\ []), do: %__MODULE__{callbacks: callbacks}
end
