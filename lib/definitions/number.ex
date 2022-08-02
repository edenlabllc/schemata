defmodule Schemata.Definitions.Number do
  @moduledoc false

  defstruct opts: [callbacks: [], null: false]

  def number() do
    %__MODULE__{}
  end

  def number(opts) do
    %__MODULE__{opts: opts}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Number do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      %{}
      |> add_type(value, "number")
      |> add_not_null_value(value, :multipleOf)
      |> add_not_null_value(value, :minimum)
      |> add_not_null_value(value, :exclusiveMinimum)
      |> add_not_null_value(value, :maximum)
      |> add_not_null_value(value, :exclusiveMaximum)

    Jason.Encode.map(encode_value, opts)
  end
end
