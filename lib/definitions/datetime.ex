defmodule Schemata.Definitions.Datetime do
  defstruct [:description]

  def datetime(description \\ ""), do: %__MODULE__{description: description}
end

defimpl Jason.Encoder, for: Schemata.Definitions.Datetime do
  def encode(value, opts) do
    Jason.Encode.map(
      %{"type" => "string", "format" => "date-time", "description" => value.description},
      opts
    )
  end
end
