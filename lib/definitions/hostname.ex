defmodule Schemata.Definitions.Hostname do
  @moduledoc false

  defstruct opts: [callbacks: []]

  def hostname() do
    %__MODULE__{}
  end

  def hostname(opts) do
    %__MODULE__{opts: opts}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Hostname do
  def encode(_, opts) do
    Jason.Encode.map(
      %{"type" => "string", "format" => "hostname"},
      opts
    )
  end
end
