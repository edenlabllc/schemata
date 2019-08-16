defmodule Schemata.Definitions.String do
  @moduledoc false

  defstruct [:minLength, :maxLength, :callbacks]

  def string(callbacks \\ []) do
    %__MODULE__{callbacks: callbacks}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.String do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      %{"type" => "string"}
      |> add_not_null_value(value, :minLength)
      |> add_not_null_value(value, :maxLength)

    Jason.Encode.map(encode_value, opts)
  end
end
