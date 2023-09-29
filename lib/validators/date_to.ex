defmodule Schemata.Validators.DateTo do
  @enforce_keys [:value]

  defstruct value: nil, equal: nil, message: nil

  def date_to(value, equal \\ nil, message \\ nil),
    do: %__MODULE__{
      value: value,
      equal: equal,
      message: message
    }
end

defimpl Schemata.Validator, for: Schemata.Validators.DateTo do
  def validate(_date_to, nil, _path),
    do: :ok

  def validate(%{value: to, equal: equal, message: message}, date, path) do
    with {:ok, date} <- Date.from_iso8601(date),
         result <- Date.compare(date, to),
         :ok <- validate_result(result, equal) do
      :ok
    else
      {:error, :invalid_format} -> :ok
      {:error, :exceeds_range} -> render_error(message, equal, to, date, path)
    end
  end

  defp validate_result(:lt, _equal),
    do: :ok

  defp validate_result(:eq, true),
    do: :ok

  defp validate_result(_result, _equal),
    do: {:error, :exceeds_range}

  defp render_error(message, equal, expected, actual, path) when is_function(message),
    do: message.(equal, expected, actual, path)

  defp render_error(message, equal, expected, actual, path) do
    [
      {
        %{
          description: build_message(message, equal, expected, actual),
          params: %{
            expected: expected,
            actual: actual
          },
          raw_description: build_raw_message(message, equal),
          rule: :date_from
        },
        path
      }
    ]
  end

  defp build_message(nil, true, expected, actual),
    do: "Date should be less than or equal to '#{expected}' but got '#{actual}'."

  defp build_message(nil, _equal, expected, actual),
    do: "Date should be less than '#{expected}' but got '#{actual}'."

  defp build_message(message, _equal, _expected, _actual),
    do: message

  defp build_raw_message(nil, true),
    do: ~S(Date should be less than or equal to '#{expected}' but got '#{actual}'.)

  defp build_raw_message(nil, _equal),
    do: ~S(Date should be less than '#{expected}' but got '#{actual}'.)

  defp build_raw_message(message, _equal),
    do: message
end
