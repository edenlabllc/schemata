defmodule Schemata.Validators.RequiredOneOf do
  @enforce_keys [:properties]

  defstruct [:properties, :message]

  def required_one_of(properties, message \\ nil),
    do: %__MODULE__{properties: Enum.map(properties, &to_string/1), message: message}
end

defimpl Schemata.Validator, for: Schemata.Validators.RequiredOneOf do
  def validate(_required_one_of, nil, _path),
    do: :ok

  def validate(%{properties: properties, message: message}, object, path) do
    case object |> Map.take(properties) |> Map.keys() do
      [_] -> :ok
      keys -> render_error(message, properties, keys, path)
    end
  end

  defp render_error(message, expected, actual, path) when is_function(message),
    do: message.(expected, actual, path)

  defp render_error(message, expected, actual, path) do
    {
      :error,
      [
        {
          %{
            description: build_message(message, expected, actual),
            params: %{
              expected_one_of: expected,
              actual: actual
            },
            raw_description: build_raw_message(message),
            rule: :required_one_of
          },
          path
        }
      ]
    }
  end

  defp build_message(nil, expected, actual),
    do:
      "One and only one key is allowed from the list: [#{Enum.join(expected, ", ")}], but the following are present: [#{Enum.join(actual, ", ")}]."

  defp build_message(message, _expected, _actual),
    do: message

  defp build_raw_message(nil),
    do:
      "One and only one key is allowed from the list: [%{expected_one_of}], but the following are present: [%{actual}]."

  defp build_raw_message(message),
    do: message
end
