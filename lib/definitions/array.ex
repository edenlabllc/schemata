defmodule Schemata.Definitions.Array do
  @moduledoc false

  defstruct type: "array",
            items: nil,
            opts: [
              additionalItems: false,
              minItems: 1,
              maxItems: nil,
              uniqueItems: false,
              callbacks: [],
              null: false
            ]

  def array(items) do
    %__MODULE__{items: items}
  end

  def array(items, opts) do
    arr = %__MODULE__{items: items}
    %{arr | opts: Keyword.merge(arr.opts, opts)}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Array do
  import Schemata.Definition

  def encode(value, opts) do
    encode_value =
      value
      |> encoded_data()
      |> add_type(value, "array")
      |> add_not_null_value(value, :additionalItems)
      |> add_not_null_value(value, :uniqueItems)
      |> add_not_null_value(value, :minItems)
      |> add_not_null_value(value, :maxItems)

    Jason.Encode.map(encode_value, opts)
  end

  defp encoded_data(%{items: nil}), do: %{}
  defp encoded_data(%{items: items}), do: %{items: items}
end
