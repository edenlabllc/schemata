defmodule Schemata.Definitions.UUID do
  @moduledoc false

  @derive {Jason.Encoder, [only: [:type, :pattern]]}

  defstruct type: "string",
            pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
            opts: [callbacks: []]

  def uuid(), do: %__MODULE__{}
  def uuid(opts), do: %__MODULE__{opts: opts}
end
