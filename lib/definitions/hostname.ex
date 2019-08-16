defmodule Schemata.Definitions.Hostname do
  @moduledoc false

  defstruct [:callbacks]

  def hostname(callbacks \\ []), do: %__MODULE__{callbacks: callbacks}
end

defimpl Jason.Encoder, for: Schemata.Definitions.Hostname do
  def encode(_, opts) do
    Jason.Encode.map(
      %{"type" => "string", "format" => "hostname"},
      opts
    )
  end
end
