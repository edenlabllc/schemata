defmodule Schemata.Definitions.Date do
  defstruct [:description]

  def date(description \\ ""), do: %__MODULE__{description: description}
end

defimpl Jason.Encoder, for: Schemata.Definitions.Date do
  def encode(value, opts) do
    Jason.Encode.map(
      %{"type" => "string", "format" => "date", "description" => value.description},
      opts
    )
  end
end
