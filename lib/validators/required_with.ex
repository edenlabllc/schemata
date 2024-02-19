defmodule Schemata.Validators.RequiredWith do
  @enforce_keys [:field, :required_with_field]

  defstruct [:field, :required_with_field, :message]

  def required_with(field, required_with_field, message \\ nil),
    do: %__MODULE__{
      field: to_string(field),
      required_with_field: to_string(required_with_field),
      message: message
    }
end

defimpl Schemata.Validator, for: Schemata.Validators.RequiredWith do
  def validate(_required_with, nil, _path),
    do: :ok

  def validate(
        %{field: field, required_with_field: required_with_field, message: message},
        object,
        path
      ) do
    case {object[field], object[required_with_field]} do
      {_, nil} -> :ok
      {nil, _} -> render_error(message, field, required_with_field, "#{path}.#{field}")
      _ -> :ok
    end
  end

  defp render_error(message, field, required_with_field, path) when is_function(message),
    do: message.(field, required_with_field, path)

  defp render_error(message, field, required_with_field, path) do
    {
      :error,
      [
        {
          %{
            description: build_message(message, field, required_with_field),
            params: %{
              field: field,
              required_with_field: required_with_field
            },
            raw_description: build_raw_message(message),
            rule: :required
          },
          path
        }
      ]
    }
  end

  defp build_message(nil, field, required_with_field),
    do: "Field '#{field}' is required when '#{required_with_field}' is present"

  defp build_message(message, _field, _required_with_field),
    do: message

  defp build_raw_message(nil),
    do: "Field '%{field}' is required when '%{required_with_field}' is present"

  defp build_raw_message(message),
    do: message
end
