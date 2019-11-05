defmodule Schemata.Definitions.Integer do
  @moduledoc false

  defstruct opts: [callbacks: [], null: false]

  def integer() do
    %__MODULE__{}
  end

  def integer(opts) do
    %__MODULE__{opts: opts}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Integer do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      %{}
      |> add_type(value, "integer")
      |> add_not_null_value(value, :minimum)
      |> add_not_null_value(value, :exclusiveMinimum)
      |> add_not_null_value(value, :maximum)
      |> add_not_null_value(value, :exclusiveMaximum)

    Jason.Encode.map(encode_value, opts)
  end
end
