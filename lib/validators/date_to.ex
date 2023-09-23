defmodule Schemata.Validators.DateTo do
  @enforce_keys [:value]

  defstruct [:value, :message]

  def date_to(value, message \\ nil),
    do: %__MODULE__{
      value: value,
      message: message || "Date should be less than or equal to '#{value}'"
    }
end

defimpl Schemata.Validator, for: Schemata.Validators.DateTo do
  def validate(%{value: to, message: message}, date, path) do
    case Date.compare(Date.from_iso8601!(date), to) do
      :eq -> :ok
      :lt -> :ok
      :gt -> render_error(message, date, path)
    end
  end

  defp render_error(message, date, path) when is_function(message),
    do: message.(date, path)

  defp render_error(message, _, _),
    do: message
end
