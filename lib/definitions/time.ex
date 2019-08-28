defmodule Schemata.Definitions.Time do
  @moduledoc false

  defstruct opts: [callbacks: [], null: false]

  def time(), do: %__MODULE__{}
  def time(opts), do: %__MODULE__{opts: opts}
end

defimpl Jason.Encoder, for: Schemata.Definitions.Time do
  import Schemata.Definition

  def encode(value, opts) do
    Jason.Encode.map(
      add_type(%{"pattern" => "^([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$"}, value, "string"),
      opts
    )
  end
end
