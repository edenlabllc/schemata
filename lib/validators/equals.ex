defmodule Schemata.Validators.Equals do
  @moduledoc false

  @enforce_keys [:value]

  defstruct [:value, :message]

  def equals(value, message \\ :error), do: %__MODULE__{value: value, message: message}
end

defimpl Schemata.Validator, for: Schemata.Validators.Equals do
  def validate(%{value: value}, value), do: :ok
  def validate(%{message: message}, _), do: message
end
