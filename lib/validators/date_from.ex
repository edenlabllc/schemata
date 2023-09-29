defmodule Schemata.Validators.DateFrom do
  @enforce_keys [:value]

  defstruct value: nil, equal: nil, message: nil

  def date_from(value, equal \\ nil, message \\ nil),
    do: %__MODULE__{
      value: value,
      equal: equal,
      message: message
    }
end

defimpl Schemata.Validator, for: Schemata.Validators.DateFrom do
  def validate(_date_from, nil, _path),
    do: :ok

  def validate(%{value: from, equal: equal, message: message}, date, path) do
    with {:ok, date} <- Date.from_iso8601(date),
         result <- Date.compare(date, from),
         :ok <- validate_result(result, equal) do
      :ok
    else
      {:error, :invalid_format} -> :ok
      {:error, :exceeds_range} -> render_error(message, equal, from, date, path)
    end
  end

  defp validate_result(:gt, _equal),
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
    do: "Date should be greater than or equal to '#{expected}' but got '#{actual}'."

  defp build_message(nil, _equal, expected, actual),
    do: "Date should be greater than '#{expected}' but got '#{actual}'."

  defp build_message(message, _equal, _expected, _actual),
    do: message

  defp build_raw_message(nil, true),
    do: ~S(Date should be greater than or equal to '#{expected}' but got '#{actual}'.)

  defp build_raw_message(nil, _equal),
    do: ~S(Date should be greater than '#{expected}' but got '#{actual}'.)

  defp build_raw_message(message, _equal),
    do: message
end
