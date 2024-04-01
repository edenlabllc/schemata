defmodule Schemata.Validators.RequiredItems do
  @enforce_keys [:value_path, :required_values]

  defstruct [:value_path, :required_values, :message]

  def required_items(value_path, required_values, message \\ nil),
    do: %__MODULE__{
      value_path: value_path,
      required_values: required_values,
      message: message
    }
end

defimpl Schemata.Validator, for: Schemata.Validators.RequiredItems do
  def validate(_required_items, nil, _path),
    do: :ok

  def validate(
        %{
          value_path: value_path,
          required_values: required_values,
          message: message
        },
        list,
        path
      ) do
    item_values = Enum.flat_map(list, fn item -> get_item_value(item, value_path) end)

    case Enum.filter(required_values, fn required_value -> required_value not in item_values end) do
      [_ | _] = items -> render_error(message, items, path)
      _ -> :ok
    end
  end

  defp get_item_value(item, []),
    do: item

  defp get_item_value(item, [path | rest]) when is_map(item),
    do: item |> Map.get(path) |> get_item_value(rest)

  defp get_item_value(item, path) when is_list(item),
    do: Enum.map(item, &get_item_value(&1, path))

  defp render_error(message, items, path) when is_function(message),
    do: message.(items, path)

  defp render_error(message, items, path) do
    {
      :error,
      [
        {
          %{
            description: build_message(message, items),
            params: %{
              required_items: items
            },
            raw_description: build_raw_message(message),
            rule: :required_items
          },
          path
        }
      ]
    }
  end

  defp build_message(nil, items),
    do: "Some of required items are not present: [#{Enum.join(items, ", ")}]"

  defp build_message(message, _items),
    do: message

  defp build_raw_message(nil),
    do: "Some of required items are not present: [%{required_items}]"

  defp build_raw_message(message),
    do: message
end
