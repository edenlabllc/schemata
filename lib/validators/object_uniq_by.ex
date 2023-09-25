defmodule Schemata.Validators.ObjectUniqBy do
  @enforce_keys [:value]

  defstruct [:value, :message]

  def object_uniq_by(value, message \\ nil),
    do: %__MODULE__{value: value, message: message || "Values are not unique."}
end

defimpl Schemata.Validator, for: Schemata.Validators.ObjectUniqBy do
  def validate(_uniq_by, nil, _path),
    do: :ok

  def validate(%{value: value, message: message}, list, path) when is_binary(value) do
    case Enum.uniq_by(list, &Map.get(&1, value)) == list do
      true -> :ok
      false -> render_error(message, list, path)
    end
  end

  def validate(%{value: value, message: message}, list, path) when is_function(value) do
    case Enum.uniq_by(list, &value.(&1)) == list do
      true -> :ok
      false -> render_error(message, list, path)
    end
  end

  defp render_error(message, list, path) when is_function(message),
    do: message.(list, path)

  defp render_error(message, _, _),
    do: message
end
