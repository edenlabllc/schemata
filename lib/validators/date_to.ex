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
  def validate(%{value: to, eq: equal, message: message}, date, path) do
    result = Date.compare(Date.from_iso8601!(date), to)

    cond do
      :lt == result -> :ok
      equal && :eq == result -> :ok
      true -> render_error(message, date, path)
    end
  end

  defp render_error(message, date, path) when is_function(message),
    do: message.(date, path)

  defp render_error(message, _, _),
    do: message
end
