defmodule Schemata.SchemaValidator do
  @moduledoc false

  alias NExJsonSchema.Validator
  alias Schemata.Definitions.Array
  alias Schemata.Definitions.Object
  alias Schemata.Definitions.Ref
  alias Schemata.Schema

  def validate(%Schema{} = schema, data) do
    nex_json_schema =
      schema
      |> Jason.encode!()
      |> Jason.decode!()
      |> NExJsonSchema.Schema.resolve()

    with :ok <- Validator.validate(nex_json_schema, data) do
      Enum.reduce_while(schema.properties, :ok, fn {k, v}, acc ->
        case validate_field(v, data[to_string(k)], schema.definitions) do
          :ok -> {:cont, acc}
          error -> {:halt, error}
        end
      end)
    end
  end

  defp run_callbacks(callbacks, data) do
    Enum.reduce_while(callbacks, :ok, fn callback, acc ->
      case Schemata.Validator.validate(callback, data) do
        :ok -> {:cont, acc}
        error -> {:halt, error}
      end
    end)
  end

  defp validate_field(
         %Array{callbacks: callbacks, items: [_ | _] = items} = array,
         data,
         definitions
       )
       when is_list(items) do
    case run_callbacks(callbacks, data) do
      :ok ->
        if is_list(data) do
          data
          |> Enum.with_index()
          |> Enum.reduce_while(:ok, fn {v, index}, acc ->
            # additional items should be validated by static validation
            schema = Enum.at(items, index, array.additionalItems)

            case validate_field(schema, v, definitions) do
              :ok -> {:cont, acc}
              error -> {:halt, error}
            end
          end)
        else
          :ok
        end

      error ->
        error
    end
  end

  defp validate_field(%Array{callbacks: callbacks, items: item}, data, definitions) do
    case run_callbacks(callbacks, data) do
      :ok ->
        if is_list(data) do
          Enum.reduce_while(data, :ok, fn v, acc ->
            case validate_field(item, v, definitions) do
              :ok -> {:cont, acc}
              error -> {:halt, error}
            end
          end)
        else
          :ok
        end

      error ->
        error
    end
  end

  defp validate_field(%Ref{ref: ref, callbacks: callbacks}, data, definitions) do
    case run_callbacks(callbacks, data) do
      :ok ->
        definition = Map.get(definitions, String.to_atom(ref))
        validate_field(definition, data, definitions)

      error ->
        error
    end
  end

  defp validate_field(%Object{callbacks: callbacks} = object, data, definitions) do
    case run_callbacks(callbacks, data) do
      :ok ->
        Enum.reduce_while(object.properties, :ok, fn {k, v}, acc ->
          case validate_field(v, data[to_string(k)], definitions) do
            :ok -> {:cont, acc}
            error -> {:halt, error}
          end
        end)

      error ->
        error
    end
  end

  defp validate_field(%{callbacks: callbacks}, data, _), do: run_callbacks(callbacks, data)
end

defprotocol Schemata.Validator do
  def validate(validator, data)
end
