defmodule Schemata.Validators.Equals do
  @moduledoc false

  @enforce_keys [:value]

  defstruct [:value, :message]

  def equals(value, message \\ :error), do: %__MODULE__{value: value, message: message}
end

defimpl Schemata.Validator, for: Schemata.Validators.Equals do
  def validate(%{value: value}, value, _), do: :ok

  def validate(%{message: message}, _, _) when is_binary(message) do
    message
  end

  def validate(%{message: message}, value, path) when is_function(message) do
    message.(value, path)
  end
end
