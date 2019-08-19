defmodule Schemata.Definitions.Date do
  @moduledoc false

  defstruct opts: [callbacks: []]

  def date() do
    %__MODULE__{}
  end

  def date(opts) do
    %__MODULE__{opts: opts}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Date do
  def encode(_, opts) do
    Jason.Encode.map(
      %{"type" => "string", "format" => "date"},
      opts
    )
  end
end
