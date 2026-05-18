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
    Enum.reduce_while(validations, nil, fn validation, first_error ->
      case Schemata.Validator.validate(validation, string, path) do
        :ok -> {:halt, :ok}
        {:error, _} = error -> {:cont, first_error || error}
      end
    end)
  end
end
