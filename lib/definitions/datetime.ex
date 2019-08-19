defmodule Schemata.Definitions.Datetime do
  @moduledoc false

  defstruct opts: [callbacks: []]

  def datetime() do
    %__MODULE__{}
  end

  def datetime(opts) do
    %__MODULE__{opts: opts}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Datetime do
  def encode(_, opts) do
    Jason.Encode.map(
      %{"type" => "string", "format" => "date-time"},
      opts
    )
  end
end
