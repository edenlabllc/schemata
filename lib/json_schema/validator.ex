defmodule Schemata.JsonSchema.Validator do
  @moduledoc false

  alias Schemata.JsonSchema.Schema
  alias Schemata.JsonSchema.Schema.Root
  alias Schemata.JsonSchema.Validator.Dependencies
  alias Schemata.JsonSchema.Validator.Format
  alias Schemata.JsonSchema.Validator.Items
  alias Schemata.JsonSchema.Validator.Properties
  alias Schemata.JsonSchema.Validator.Type

  @type error_details :: %{
          rule: atom(),
          params: map(),
          description: String.t(),
          raw_description: String.t()
        }
  @type errors :: [{error_details(), String.t()}]
  @type errors_with_list_paths :: [{error_details(), [String.t() | integer()]}]

  @path_item_regex ~r/^(\[\d+\]|\$)$/

  @spec validate(Root.t() | Schemata.JsonSchema.json(), Schemata.JsonSchema.data()) ::
          :ok | {:error, errors()}
  def validate(root = %Root{}, data) do
    errors = root |> validate(root.schema, data, ["$"]) |> errors_with_string_paths

    case Enum.empty?(errors) do
      true -> :ok
      false -> {:error, errors}
    end
  end

  def validate(schema = %{}, data) do
    validate(Schema.resolve(schema), data)
  end

  @spec validate(Root.t(), Schema.resolved(), Schemata.JsonSchema.data(), [String.t() | integer()]) ::
          errors_with_list_paths()
  def validate(root, schema, data, path \\ []) do
    schema
    |> Enum.flat_map(&validate_aspect(root, schema, &1, data))
    |> Enum.map(fn {%{} = rules, p} -> {rules, path ++ p} end)
  end

  @spec valid?(Root.t() | Schemata.JsonSchema.json(), Schemata.JsonSchema.data()) :: boolean()
  def valid?(root = %Root{}, data), do: valid?(root, root.schema, data)

  def valid?(schema = %{}, data), do: valid?(Schema.resolve(schema), data)

  @spec valid?(Root.t(), Schema.resolved(), Schemata.JsonSchema.data()) :: boolean()
  def valid?(root, schema, data), do: root |> validate(schema, data) |> Enum.empty?()

  defp errors_with_string_paths(errors) do
    Enum.map(errors, fn {msg, path} -> {msg, join_path(path)} end)
  end

  def format_error(rule, raw_description, params \\ []) do
    %{
      raw_description: raw_description,
      description: format_description(raw_description, params),
      rule: rule,
      params: Map.new(params)
    }
  end

  defp validate_aspect(root, _, {"$ref", path}, data) do
    schema = Schema.get_ref_schema(root, path)
    validate(root, schema, data)
  end

  defp validate_aspect(root, _, {"allOf", all_of}, data) do
    invalid_indexes = validation_result_indexes(root, all_of, data, &(!elem(&1, 0)))

    case Enum.empty?(invalid_indexes) do
      true ->
        []

      false ->
        [
          {format_error(
             :schemata,
             "expected all of the schemata to match, but the schemata at the following indexes did not: %{indexes}",
             indexes: invalid_indexes
           ), []}
        ]
    end
  end

  defp validate_aspect(root, _, {"anyOf", any_of}, data) do
    case Enum.any?(any_of, &valid?(root, &1, data)) do
      true ->
        []

      false ->
        [{format_error(:schemata, "expected any of the schemata to match but none did"), []}]
    end
  end

  defp validate_aspect(root, _, {"oneOf", one_of}, data) do
    valid_indexes = validation_result_indexes(root, one_of, data, &elem(&1, 0))

    case Enum.empty?(valid_indexes) do
      true ->
        [
          {format_error(
             :schemata,
             "expected exactly one of the schemata to match, but none of them did"
           ), []}
        ]

      false ->
        if Enum.count(valid_indexes) == 1 do
          []
        else
          [
            {format_error(
               :schemata,
               "expected exactly one of the schemata to match, but the schemata at the following indexes did: %{indexes}",
               indexes: valid_indexes
             ), []}
          ]
        end
    end
  end

  defp validate_aspect(root, _, {"not", not_schema}, data) do
    case valid?(root, not_schema, data) do
      true ->
        [
          {format_error(
             :schema,
             "expected schema not to match but it did"
           ), []}
        ]

      false ->
        []
    end
  end

  defp validate_aspect(_, _, {"type", type}, data) do
    Type.validate(type, data)
  end

  defp validate_aspect(root, schema, {"properties", _}, data = %{}) do
    Properties.validate(root, schema, data)
  end

  defp validate_aspect(_, _, {"minProperties", min_properties}, data) when is_map(data) do
    case map_size(data) >= min_properties do
      true ->
        []

      false ->
        [
          {format_error(
             :length,
             "expected a minimum of %{min} properties but got %{actual}",
             min: min_properties,
             actual: map_size(data)
           ), []}
        ]
    end
  end

  defp validate_aspect(_, _, {"maxProperties", max_properties}, data) when is_map(data) do
    case map_size(data) <= max_properties do
      true ->
        []

      false ->
        [
          {format_error(
             :length,
             "expected a maximum of %{max} properties but got %{actual}",
             max: max_properties,
             actual: map_size(data)
           ), []}
        ]
    end
  end

  defp validate_aspect(_, _, {"required", required}, data = %{}) do
    Enum.flat_map(List.wrap(required), fn property ->
      case Map.has_key?(data, property) do
        true ->
          []

        false ->
          [
            {format_error(
               :required,
               "required property %{property} was not present",
               property: property
             ), [property]}
          ]
      end
    end)
  end

  defp validate_aspect(root, _, {"dependencies", dependencies}, data) do
    Dependencies.validate(root, dependencies, data)
  end

  defp validate_aspect(root, schema, {"items", _}, items) do
    Items.validate(root, schema, items)
  end

  defp validate_aspect(_, _, {"minItems", min_items}, items) when is_list(items) do
    case (count = Enum.count(items)) >= min_items do
      true ->
        []

      false ->
        [
          {format_error(
             :length,
             "expected a minimum of %{min} items but got %{actual}",
             min: min_items,
             actual: count
           ), []}
        ]
    end
  end

  defp validate_aspect(_, _, {"maxItems", max_items}, items) when is_list(items) do
    case (count = Enum.count(items)) <= max_items do
      true ->
        []

      false ->
        [
          {format_error(
             :length,
             "expected a maximum of %{max} items but got %{actual}",
             max: max_items,
             actual: count
           ), []}
        ]
    end
  end

  defp validate_aspect(_, _, {"uniqueItems", true}, items) when is_list(items) do
    case Enum.uniq(items) == items do
      true ->
        []

      false ->
        [
          {format_error(
             :unique,
             "expected items to be unique but they were not"
           ), []}
        ]
    end
  end

  defp validate_aspect(_, _, {"enum", enum}, data) do
    case Enum.any?(enum, &(&1 === data)) do
      true ->
        []

      false ->
        [
          {format_error(
             :inclusion,
             "value is not allowed in enum",
             values: enum
           ), []}
        ]
    end
  end

  defp validate_aspect(_, schema, {"minimum", minimum}, data) when is_number(data) do
    exclusive? = schema["exclusiveMinimum"]
    fun = if exclusive?, do: &Kernel.>/2, else: &Kernel.>=/2

    case fun.(data, minimum) do
      true ->
        []

      false ->
        [
          {format_error(
             :number,
             "expected the value to be #{if exclusive?, do: "> %{greater_than}", else: ">= %{greater_than_or_equal_to}"}",
             get_number_validation_params(:minimum, minimum, exclusive?)
           ), []}
        ]
    end
  end

  defp validate_aspect(_, schema, {"maximum", maximum}, data) when is_number(data) do
    exclusive? = schema["exclusiveMaximum"]
    fun = if exclusive?, do: &Kernel.</2, else: &Kernel.<=/2

    case fun.(data, maximum) do
      true ->
        []

      false ->
        [
          {format_error(
             :number,
             "expected the value to be #{if exclusive?, do: "< %{less_than}", else: "<= %{less_than_or_equal_to}"}",
             get_number_validation_params(:maximum, maximum, exclusive?)
           ), []}
        ]
    end
  end

  defp validate_aspect(_, _, {"multipleOf", multiple_of}, data) when is_number(data) do
    zero = Decimal.new(0)
    dec_multiple_of = dec(multiple_of)
    dec_data = dec(data)

    cond do
      dec_multiple_of == zero -> [multiple_of_error(multiple_of, data)]
      dec_data == zero -> []
      Decimal.integer?(Decimal.div(dec_data, dec_multiple_of)) -> []
      true -> [multiple_of_error(multiple_of, data)]
    end
  end

  defp validate_aspect(_, _, {"minLength", min_length}, data) when is_binary(data) do
    case (length = String.length(data)) >= min_length do
      true ->
        []

      false ->
        [
          {format_error(
             :length,
             "expected value to have a minimum length of %{min} but was %{actual}",
             min: min_length,
             actual: length
           ), []}
        ]
    end
  end

  defp validate_aspect(_, _, {"maxLength", max_length}, data) when is_binary(data) do
    case (length = String.length(data)) <= max_length do
      true ->
        []

      false ->
        [
          {format_error(
             :length,
             "expected value to have a maximum length of %{max} but was %{actual}",
             max: max_length,
             actual: length
           ), []}
        ]
    end
  end

  defp validate_aspect(_, _, {"pattern", pattern}, data) when is_binary(data) do
    case pattern |> Regex.compile!("u") |> Regex.match?(data) do
      true ->
        []

      false ->
        [
          {format_error(
             :format,
             "string does not match pattern \"%{pattern}\"",
             pattern: pattern
           ), []}
        ]
    end
  end

  defp validate_aspect(_, _, {"format", format}, data) do
    Format.validate(format, data)
  end

  defp validate_aspect(_, _, _, _), do: []

  defp dec(number) do
    if is_float(number) do
      Decimal.from_float(number)
    else
      Decimal.new(number)
    end
  end

  defp multiple_of_error(multiple_of, data) do
    {format_error(
       :number,
       "expected value to be a multiple of %{multiple_of} but got %{actual}",
       multiple_of: multiple_of,
       actual: data
     ), []}
  end

  defp format_description(raw_description, params) do
    Enum.reduce(params, raw_description, fn {key, value}, acc ->
      template = "%{#{key}}"

      case String.contains?(acc, template) do
        true -> String.replace(acc, template, format_parameter(value))
        false -> acc
      end
    end)
  end

  defp format_parameter(value) when is_list(value), do: Enum.join(value, ", ")
  defp format_parameter(value), do: to_string(value)

  defp get_number_validation_params(:maximum, value, true), do: [less_than: value]
  defp get_number_validation_params(:maximum, value, _), do: [less_than_or_equal_to: value]
  defp get_number_validation_params(:minimum, value, true), do: [greater_than: value]
  defp get_number_validation_params(:minimum, value, _), do: [greater_than_or_equal_to: value]

  defp validation_result_indexes(root, schemata, data, filter) do
    schemata
    |> Enum.map(&valid?(root, &1, data))
    |> Enum.with_index()
    |> Enum.filter(filter)
    |> values()
  end

  defp values(map) when is_map(map), do: Map.values(map)
  defp values(list) when is_list(list), do: Keyword.values(list)

  defp join_path(path, acc \\ "")

  defp join_path([], acc), do: acc

  defp join_path([path_item | path], acc) do
    path_item_str = if is_binary(path_item), do: path_item, else: to_string(path_item)

    if String.match?(path_item_str, @path_item_regex) do
      join_path(path, acc <> path_item_str)
    else
      join_path(path, acc <> "." <> path_item_str)
    end
  end
end
