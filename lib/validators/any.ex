defmodule Schemata.Validators.Any do
  @enforce_keys [:validations]

  defstruct [:validations]

  def any(validations) do
    %__MODULE__{validations: validations}
  end
end

defimpl Schemata.Validator, for: Schemata.Validators.Any do
  alias Schemata.Validators.Any

  def validate(_any, nil, _path),
    do: :ok

  def validate(%Any{} = any, string, path),
    do: do_validate(any.validations, string, path)

  defp do_validate(validations, string, path) do
    validations
    |> Enum.reduce_while([], fn
      {validation, message}, errors ->
        case Schemata.Validator.validate(validation, string, path) do
          :ok -> {:halt, []}
          {:error, error} -> {:cont, [format_message(error, message) | errors]}
        end

      validation, errors ->
        case Schemata.Validator.validate(validation, string, path) do
          :ok -> {:halt, []}
          {:error, error} -> {:cont, [error | errors]}
        end
    end)
    |> format_result()
  end

  defp format_message(errors, message) do
    Enum.map(errors, fn {%{description: description, raw_description: raw_description} = error,
                         path} ->
      new_description =
        description
        |> String.trim_trailing(".")
        |> Kernel.<>(". #{message}")

      new_raw_description =
        raw_description
        |> String.trim_trailing(".")
        |> Kernel.<>(". #{message}")

      {%{error | description: new_description, raw_description: new_raw_description}, path}
    end)
  end

  defp format_result([]),
    do: :ok

  defp format_result(errors),
    do: {:error, Enum.reverse(errors)}
end
