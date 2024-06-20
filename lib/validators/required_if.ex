defmodule Schemata.Validators.RequiredIf do
  @enforce_keys [:field, :required_if_field, :required_if_value]

  defstruct [:field, :required_if_field, :required_if_value, :message]

  def required_if(field, required_if_field, required_if_value, message \\ nil),
    do: %__MODULE__{
      field: to_string(field),
      required_if_field: to_string(required_if_field),
      required_if_value: required_if_value,
      message: message
    }
end

defimpl Schemata.Validator, for: Schemata.Validators.RequiredIf do
  def validate(_required_if, nil, _path),
    do: :ok

  def validate(rule, object, path) do
    case {object[rule.field], object[rule.required_if_field] == rule.required_if_value} do
      {_, false} ->
        :ok

      {nil, true} ->
        render_error(
          rule.message,
          rule.field,
          rule.required_if_field,
          rule.required_if_value,
          "#{path}.#{rule.field}"
        )

      _ ->
        :ok
    end
  end

  defp render_error(message, field, required_if_field, required_if_value, path)
       when is_function(message),
       do: message.(field, required_if_field, required_if_value, path)

  defp render_error(message, field, required_if_field, required_if_value, path) do
    {
      :error,
      [
        {
          %{
            description: build_message(message, field, required_if_field, required_if_value),
            params: %{
              field: field,
              required_if_field: required_if_field,
              required_if_value: required_if_value
            },
            raw_description: build_raw_message(message),
            rule: :required
          },
          path
        }
      ]
    }
  end

  defp build_message(nil, field, required_if_field, required_if_value),
    do: "Field '#{field}' is required when '#{required_if_field}' = #{inspect(required_if_value)}"

  defp build_message(message, _field, _required_if_field, _required_if_value),
    do: message

  defp build_raw_message(nil),
    do: "Field '%{field}' is required when '%{required_if_field}' = %{required_if_value}"

  defp build_raw_message(message),
    do: message
end
