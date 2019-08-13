defmodule Schemata.Definition do
  @moduledoc false

  def with_opts(value, opts) when is_list(opts) do
    Map.merge(value, Enum.into(opts, %{}))
  end

  def with_opts(value, opts) when is_map(opts) do
    Map.merge(
      value,
      Enum.into(opts, %{}, fn
        {k, v} when is_binary(k) -> {String.to_atom(k), v}
        {k, v} when is_atom(k) -> {k, v}
      end)
    )
  end

  def add_not_null_value(state, data, field) do
    case Map.get(data, field) do
      nil ->
        state

      "" ->
        state

      %{} ->
        state

      value ->
        Map.put(state, field, value)
    end
  end
end
