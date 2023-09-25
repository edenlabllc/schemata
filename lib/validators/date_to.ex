defmodule Schemata.Validators.DateTo do
  @enforce_keys [:value]

  defstruct value: nil, eq: false, message: nil

  def date_to(value, eq \\ nil, message \\ nil),
    do: %__MODULE__{
      value: value,
      eq: eq,
      message: message || "Date should be less than or equal to '#{value}'"
    }
end

defimpl Schemata.Validator, for: Schemata.Validators.DateTo do
  def validate(_date_to, nil, _path),
    do: :ok

  def validate(%{value: to, eq: equal, message: message}, date, path) do
    with {:ok, date} <- Date.from_iso8601(date),
         result <- Date.compare(date, to),
         :ok <- validate_result(result, equal) do
      :ok
    else
      {:error, :invalid_format} -> :ok
      {:error, :exceeds_range} -> render_error(message, date, path)
    end
  end

  defp validate_result(:lt, _equal),
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
