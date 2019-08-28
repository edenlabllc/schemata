defmodule Schemata.Definitions.String do
  @moduledoc false

  defstruct opts: [callbacks: [], null: false]

  def string() do
    %__MODULE__{}
  end

  def string(opts) do
    %__MODULE__{opts: opts}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.String do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      add_type(%{}, value, "string")
      |> add_not_null_value(value, :minLength)
      |> add_not_null_value(value, :maxLength)

    Jason.Encode.map(encode_value, opts)
  end
end
