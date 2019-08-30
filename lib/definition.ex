defmodule Schemata.Definition do
  @moduledoc false

  def add_not_null_value(state, data, field) do
    opts = data.opts

    case Keyword.get(opts, field) do
      nil ->
        state

      "" ->
        state

      [] = value when value == [] ->
        state

      %{} = value when value == %{} ->
        state

      value ->
        Map.put(state, field, value)
    end
  end

  def add_type(state, data, default) do
    opts = data.opts
    type = if Keyword.get(opts, :null), do: [default, "null"], else: default
    Map.merge(state, %{type: type})
  end

  def null(definition, value \\ true) do
    opts = definition.opts
    %{definition | opts: Keyword.put(opts, :null, value)}
  end
end
