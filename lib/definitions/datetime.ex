defmodule Schemata.Definitions.Datetime do
  @moduledoc false

  defstruct opts: [callbacks: [], null: false]

  def datetime() do
    %__MODULE__{}
  end

  def datetime(opts) do
    %__MODULE__{opts: opts}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Datetime do
  import Schemata.Definition

  def encode(value, opts) do
    Jason.Encode.map(
      add_type(%{"format" => "date-time"}, value, "string"),
      opts
    )
  end
end
