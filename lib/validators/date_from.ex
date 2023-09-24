defmodule Schemata.Validators.DateFrom do
  @enforce_keys [:value]

  defstruct value: nil, eq: false, message: nil

  def date_from(value, eq \\ nil, message \\ nil),
    do: %__MODULE__{
      value: value,
      eq: eq,
      message: message || "Date should be greater than or equal to '#{value}'"
    }
end

defimpl Schemata.Validator, for: Schemata.Validators.DateFrom do
  def validate(_date_from, nil, _path),
    do: :ok

  def validate(%{value: from, eq: equal, message: message}, date, path) do
    with {:ok, date} <- Date.from_iso8601(date),
         result <- Date.compare(date, from),
         :ok <- validate_result(result, equal) do
      :ok
    else
      {:error, :invalid_format} -> :ok
      {:error, :exceeds_range} -> render_error(message, date, path)
    end
  end

  defp validate_result(:gt, _equal),
    do: :ok

  defp validate_result(:eq, true),
    do: :ok

  defp validate_result(_result, _equal),
    do: {:error, :exceeds_range}

  defp render_error(message, date, path) when is_function(message),
    do: message.(date, path)

  defp render_error(message, _, _),
    do: message
end
