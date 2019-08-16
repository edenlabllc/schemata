defmodule Schemata.Definitions.Date do
  @moduledoc false

  defstruct callbacks: []

  def date(callbacks \\ []), do: %__MODULE__{callbacks: callbacks}
end

defimpl Jason.Encoder, for: Schemata.Definitions.Date do
  def encode(_, opts) do
    Jason.Encode.map(
      %{"type" => "string", "format" => "date"},
      opts
    )
  end
end
