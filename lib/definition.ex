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
end
