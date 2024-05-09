defmodule Schemata.Validators.ValidateIf do
  # TODO: refactor to be more common

  @moduledoc """
  Validate list of objects by filters map. If :base_field value is equal to key in filters map,
  then :filter_field value must match regexp/string/float comparator or validated by custom function from value in filters map.

  Float comparators:
  - :eq - equal
  - :gt - greater than
  - :gte - greater than or equal
  - :lt - less than
  - :lte - less than or equal
  - :ne - not equal

  example:
  if document type is equal to "BIRTH_CERTIFICATE", then document number must match regexp

        documents_relationship:
          array(ref("document"),
            minItems: 1,
            callbacks: [
              validate_if(
                %{
                  "PASSPORT" => ~r/^((?![ЫЪЭЁ])([А-ЯҐЇІЄ])){2}[0-9]{6}$/u,
                  "NATIONAL_ID" => ~r/^[0-9]{9}$/u,
                  "BIRTH_CERTIFICATE" =>
                    ~r/^((?![ЫЪЭЁыъэё@%&$^#`~:,.*|}{?!])[A-ZА-ЯҐЇІЄ0-9№\\\/()-]){2,25}$/u,
                  "COMPLEMENTARY_PROTECTION_CERTIFICATE" =>
                    ~r/^((?![ЫЪЭЁ])([А-ЯҐЇІЄ])){2}[0-9]{6}$/u,
                  "REFUGEE_CERTIFICATE" => ~r/^((?![ЫЪЭЁ])([А-ЯҐЇІЄ])){2}[0-9]{6}$/u,
                  "TEMPORARY_CERTIFICATE" =>
                    ~r/^(((?![ЫЪЭЁ])([А-ЯҐЇІЄ])){2}[0-9]{4,6}|[0-9]{9}|((?![ЫЪЭЁ])([А-ЯҐЇІЄ])){2}[0-9]{5}\\\/[0-9]{5})$/u,
                  "TEMPORARY_PASSPORT" =>
                    ~r/^((?![ЫЪЭЁыъэё@%&$^#`~:,.*|}{?!])[A-ZА-ЯҐЇІЄ0-9№\\\/()-]){2,25}$/u,
                  "TYPE_VALIDATED_BY_CUSTOM_FUNTION" => &String.starts_with?(&1, "123"),
                  "TYPE_VALIDATED_BY_FLOAT" => {:gt, 0.0},
                  "TYPE_VALIDATED_BY_STRING" => "123"
                },
                base_field: "type",
                filter_field: "number",
                message: fn rule, field_value, filter_field, filter ->
                  {
                    %{
                      description: "string does not match pattern \"\#{filter}\"",
                      params: %{
                        value: field_value,
                        filter: filter
                      },
                      raw_description:
                        "string does not match pattern \"%{pattern}\"",
                      rule: rule
                    },
                    filter_field
                  }
                end
              )
            ]
          )
  """

  @default_options [
    base_field: "type",
    filter_field: "number",
    message: "string does not match pattern",
    rule: :validate_if
  ]

  @enforce_keys [:filters_map, :message, :base_field, :filter_field, :rule]

  defstruct [:filters_map, :message, :base_field, :filter_field, :rule]

  def validate_if(filters_map, options \\ @default_options) do
    options = Keyword.merge(@default_options, options)

    %__MODULE__{
      filters_map: filters_map,
      message: options[:message],
      base_field: options[:base_field],
      filter_field: options[:filter_field],
      rule: options[:rule]
    }
  end
end

defimpl Schemata.Validator, for: Schemata.Validators.ValidateIf do
  def validate(_config, nil, _path),
    do: :ok

  def validate(config, value, path) when is_list(value) do
    value
    |> Enum.with_index()
    |> validate_list(config, path)
  end

  def validate(%{filter_field: filter_field, message: message, rule: rule} = config, value, path)
      when is_map(value) do
    case validate_map(config, value) do
      :ok ->
        :ok

      {:error, {:invalid_value, filter, field_value}} ->
        {:error, render_error(message, rule, field_value, "#{path}.#{filter_field}", filter)}
    end
  end

  defp validate_list(list, config, path) do
    errors_acc = []
    validate_list(list, config, path, errors_acc)
  end

  defp validate_list([], _config, _path, []), do: :ok

  defp validate_list([], _config, _path, errors_acc), do: {:error, errors_acc}

  defp validate_list(
         [{value, index} | tail],
         %{message: message, rule: rule} = config,
         path,
         errors_acc
       ) do
    case validate_map(config, value) do
      :ok ->
        validate_list(tail, config, path, errors_acc)

      {:error, {:invalid_value, filter, field_value}} ->
        error_path = "#{path}.[#{index}].#{config.filter_field}"
        error = render_error(message, rule, field_value, error_path, filter)

        errors_acc =
          case error do
            error when is_list(error) -> error ++ errors_acc
            error -> [error | errors_acc]
          end

        validate_list(tail, config, path, errors_acc)
    end
  end

  def validate_map(
        %{base_field: base_field, filter_field: filter_field, filters_map: filters_map},
        value
      ) do
    with {:ok, base_field_value} <- Map.fetch(value, base_field),
         {:ok, filter} <- Map.fetch(filters_map, base_field_value),
         {:ok, field_value} <- Map.fetch(value, filter_field),
         :ok <- validate_value(field_value, filter) do
      :ok
    else
      :error -> :ok
      error -> error
    end
  end

  defp validate_value(value, %Regex{} = filter) do
    if String.match?(value, filter) do
      :ok
    else
      {:error, {:invalid_value, Regex.source(filter), value}}
    end
  end

  defp validate_value(value, filter) when is_binary(filter) do
    if filter == value do
      :ok
    else
      {:error, {:invalid_value, filter, value}}
    end
  end

  defp validate_value(value, filter) when is_function(filter) do
    if filter.(value) do
      :ok
    else
      {:error, {:invalid_value, filter, value}}
    end
  end

  defp validate_value(value, {operation, filter_value}) when is_binary(value) do
    with {parsed_value, _} <- Float.parse(value) do
      validate_value(parsed_value, {operation, filter_value})
    end
  end

  defp validate_value(value, {operation, filter_value} = filter) when is_float(value) do
    result =
      case operation do
        :eq -> value == filter_value
        :gt -> value > filter_value
        :gte -> value >= filter_value
        :lt -> value < filter_value
        :lte -> value <= filter_value
        :ne -> value != filter_value
      end

    if result do
      :ok
    else
      {:error, {:invalid_value, filter, value}}
    end
  end

  defp render_error(message, rule, value, path, filter) when is_function(message),
    do: message.(rule, value, path, filter)

  defp render_error(message, rule, value, path, filter) do
    [
      {
        %{
          description: message,
          params: %{
            value: value,
            filter: filter
          },
          raw_description: message,
          rule: rule
        },
        path
      }
    ]
  end
end
