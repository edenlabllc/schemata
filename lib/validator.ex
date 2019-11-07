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
        case validate_field(v, data[to_string(k)], schema.definitions, "$.#{k}") do
          :ok -> {:cont, acc}
          error -> {:halt, error}
        end
      end)
    end
  end

  defp run_callbacks([_ | _] = callbacks, data, path) do
    Enum.reduce_while(callbacks, :ok, fn callback, acc ->
      case Schemata.Validator.validate(callback, data, path) do
        :ok -> {:cont, acc}
        error -> {:halt, error}
      end
    end)
  end

  defp run_callbacks(_, _, _), do: :ok

  defp validate_field(
         %Array{opts: opts, items: [_ | _] = items} = array,
         data,
         definitions,
         path
       )
       when is_list(items) do
    case run_callbacks(Keyword.get(opts, :callbacks), data, path) do
      :ok ->
        if is_list(data) do
          data
          |> Enum.with_index()
          |> Enum.reduce_while(:ok, fn {v, index}, acc ->
            # additional items should be validated by static validation
            schema = Enum.at(items, index, Keyword.get(array.opts, :additionalItems, []))

            case validate_field(schema, v, definitions, path <> ".#{index}") do
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

  defp validate_field(%Array{opts: opts, items: item}, data, definitions, path) do
    case run_callbacks(Keyword.get(opts, :callbacks), data, path) do
      :ok ->
        if is_list(data) do
          Enum.reduce_while(data, :ok, fn v, acc ->
            case validate_field(item, v, definitions, path <> ".0") do
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

  defp validate_field(%Ref{ref: ref, opts: opts}, data, definitions, path) do
    case run_callbacks(Keyword.get(opts, :callbacks), data, path) do
      :ok ->
        definition = Map.get(definitions, String.to_atom(ref))
        validate_field(definition, data, definitions, path)

      error ->
        error
    end
  end

  defp validate_field(%Object{opts: opts}, nil, _, path) do
    run_callbacks(Keyword.get(opts, :callbacks), nil, path)
  end

  defp validate_field(%Object{opts: opts} = object, data, definitions, path) do
    case run_callbacks(Keyword.get(opts, :callbacks), data, path) do
      :ok ->
        Enum.reduce_while(object.properties, :ok, fn {k, v}, acc ->
          case validate_field(v, data[to_string(k)], definitions, path <> ".#{k}") do
            :ok -> {:cont, acc}
            error -> {:halt, error}
          end
        end)

      error ->
        error
    end
  end

  defp validate_field(%{opts: opts}, data, _, path) do
    run_callbacks(Keyword.get(opts, :callbacks), data, path)
  end
end

defprotocol Schemata.Validator do
  def validate(validator, data, path)
end
