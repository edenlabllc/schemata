defmodule Schemata.Definitions.Date do
  @moduledoc false

  defstruct opts: [callbacks: [], null: false]

  def date() do
    %__MODULE__{}
  end

  def date(opts) do
    %__MODULE__{opts: opts}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Date do
  import Schemata.Definition

  def encode(value, opts) do
    Jason.Encode.map(
      add_type(%{"format" => "date"}, value, "string"),
      opts
    )
  end
end
