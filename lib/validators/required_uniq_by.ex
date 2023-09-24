defmodule Schemata.Validators.RequiredUniqBy do
  @enforce_keys [:value]

  defstruct [:value, :message]

  def required_uniq_by(value, message \\ nil),
    do: %__MODULE__{value: value, message: message || "Only one and unqiue field is required."}
end

defimpl Schemata.Validator, for: Schemata.Validators.RequiredUniqBy do
  def validate(_required_uniq_by, nil, _path),
    do: :ok

  def validate(%{value: {key, value}, message: message}, list, path) do
    case Enum.filter(list, &(Map.get(&1, key) == value)) do
      [_] -> :ok
      _ -> render_error(message, list, path)
    end
  end

  def validate(%{value: value, message: message}, list, path) when is_function(value) do
    case Enum.filter(list, &value.(&1)) do
      [_] -> :ok
      _ -> render_error(message, list, path)
    end
  end

  defp render_error(message, list, path) when is_function(message),
    do: message.(list, path)

  defp render_error(message, _, _),
    do: message
end
