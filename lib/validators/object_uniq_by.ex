defmodule Schemata.Validators.ObjectUniqBy do
  @enforce_keys [:value]

  defstruct [:value, :message]

  def object_uniq_by(value, message \\ nil),
    do: %__MODULE__{value: value, message: message}
end

defimpl Schemata.Validator, for: Schemata.Validators.ObjectUniqBy do
  def validate(_uniq_by, nil, _path),
    do: :ok

  def validate(%{value: value, message: message}, list, path) when is_binary(value) do
    case Enum.uniq_by(list, &Map.get(&1, value)) == list do
      true -> :ok
      false -> render_error(message, value, list, path)
    end
  end

  def validate(%{value: value, message: message}, list, path) when is_function(value) do
    case Enum.uniq_by(list, &value.(&1)) == list do
      true -> :ok
      false -> render_error(message, nil, list, path)
    end
  end

  defp render_error(message, value, list, path) when is_function(message),
    do: message.(value, list, path)

  defp render_error(message, value, list, path) do
    {
      :error,
      [
        {
          %{
            description: build_message(message, value),
            params: %{
              value: value,
              values: list
            },
            raw_description: build_raw_message(message, value),
            rule: :object_uniq_by
          },
          path
        }
      ]
    }
  end

  defp build_message(nil, value) when is_binary(value),
    do: "Values are not unique by '#{value}'."

  defp build_message(nil, _value),
    do: "Values are not unique."

  defp build_message(message, _value),
    do: message

  defp build_raw_message(nil, value) when is_binary(value),
    do: "Values are not unique by '%{value}'."

  defp build_raw_message(nil, _value),
    do: "Values are not unique."

  defp build_raw_message(message, _value),
    do: message
end
