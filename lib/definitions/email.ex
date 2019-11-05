defmodule Schemata.Definitions.Email do
  @moduledoc false

  defstruct opts: [callbacks: [], null: false]

  def email() do
    %__MODULE__{}
  end

  def email(opts) do
    %__MODULE__{opts: opts}
  end
end

defimpl Jason.Encoder, for: Schemata.Definitions.Email do
  import Schemata.Definition

  def encode(value, opts) do
    Jason.Encode.map(
      add_type(%{"format" => "email"}, value, "string"),
      opts
    )
  end
end
