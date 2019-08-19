defmodule Schemata.Definitions.Number do
  @moduledoc false

  defstruct opts: [callbacks: []]

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
      %{"type" => "number"}
      |> add_not_null_value(value, :minimum)
      |> add_not_null_value(value, :exclusiveMinimum)
      |> add_not_null_value(value, :maximum)
      |> add_not_null_value(value, :exclusiveMaximum)

    Jason.Encode.map(encode_value, opts)
  end
end
