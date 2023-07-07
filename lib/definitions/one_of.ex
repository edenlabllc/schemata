defmodule Schemata.Definitions.OneOf do
  @moduledoc false

  @enforce_keys [:one_of]

  defstruct one_of: [],
            opts: [
              callbacks: [],
              null: false
            ]

  def one_of(one_of) do
    %__MODULE__{one_of: one_of}
  end

  def one_of(one_of, opts) do
    obj = %__MODULE__{one_of: one_of}
    %{obj | opts: Keyword.merge(obj.opts, opts)}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.OneOf do
  def encode(%{one_of: one_of}, opts) do
    Jason.Encode.map(%{"oneOf" => one_of}, opts)
  end
end
