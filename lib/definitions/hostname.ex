defmodule Schemata.Definitions.Hostname do
  defstruct [:description]

  def hostname(description \\ ""), do: %__MODULE__{description: description}
end

defimpl Jason.Encoder, for: Schemata.Definitions.Hostname do
  def encode(value, opts) do
    Jason.Encode.map(
      %{"type" => "string", "format" => "hostname", "description" => value.description},
      opts
    )
  end
end
