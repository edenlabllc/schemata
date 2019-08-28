defmodule Schemata.Definitions.Hostname do
  @moduledoc false

  defstruct opts: [callbacks: [], null: false]

  def hostname() do
    %__MODULE__{}
  end

  def hostname(opts) do
    %__MODULE__{opts: opts}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Hostname do
  import Schemata.Definition

  def encode(value, opts) do
    Jason.Encode.map(
      add_type(%{"format" => "hostname"}, value, "string"),
      opts
    )
  end
end
