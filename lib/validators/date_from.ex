defmodule Schemata.Validators.DateFrom do
  @enforce_keys [:value]

  defstruct [:value, :message]

  def date_from(value, message \\ nil),
    do: %__MODULE__{
      value: value,
      message: message || "Date should be greater than or equal to '#{value}'"
    }
end

defimpl Schemata.Validator, for: Schemata.Validators.DateFrom do
  def validate(%{value: from, message: message}, date, path) do
    case Date.compare(Date.from_iso8601!(date), from) do
      :eq -> :ok
      :gt -> :ok
      :lt -> render_error(message, date, path)
    end
  end

  defp render_error(message, date, path) when is_function(message),
    do: message.(date, path)

  defp render_error(message, _, _),
    do: message
end
