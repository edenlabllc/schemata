defmodule Schemata.JsonSchema.Schema.Root do
  @moduledoc false

  defstruct schema: %{}, refs: %{}, location: :root

  @type t :: %Schemata.JsonSchema.Schema.Root{
          schema: Schemata.JsonSchema.Schema.resolved(),
          refs: %{String.t() => Schemata.JsonSchema.Schema.resolved()},
          location: :root | String.t()
        }
end
