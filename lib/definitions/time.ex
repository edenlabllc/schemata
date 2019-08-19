defmodule Schemata.Definitions.Time do
  @moduledoc false

  defstruct opts: [callbacks: []]

  def time(), do: %__MODULE__{}
  def time(opts), do: %__MODULE__{opts: opts}
end

defimpl Jason.Encoder, for: Schemata.Definitions.Time do
  def encode(_, opts) do
    Jason.Encode.map(
      %{"type" => "string", "pattern" => "^([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$"},
      opts
    )
  end
end
