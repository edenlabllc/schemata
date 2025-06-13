defmodule Schemata.Validators.Regexs do
  @enforce_keys [:regexs]

  defstruct [:regexs, :should_match_message, :should_not_match_message]

  def regexs(regexs, should_match_message \\ nil, should_not_match_message \\ nil) do
    %__MODULE__{
      regexs: regexs,
      should_match_message: should_match_message,
      should_not_match_message: should_not_match_message
    }
  end
end

defimpl Schemata.Validator, for: Schemata.Validators.Regexs do
  alias Schemata.Validators.Regexs

  def validate(_regexs, nil, _path),
    do: :ok

  def validate(%Regexs{} = regexs, string, path),
    do: do_validate(regexs.regexs, string, regexs, path)

  defp do_validate([], _string, _regexs, _path),
    do: :ok

  defp do_validate([{:not, regex} | tail], string, regexs, path) do
    if Regex.match?(regex, string) do
      render_error(:not, regexs.should_match_message, string, Regex.source(regex), path)
    else
      do_validate(tail, string, regexs, path)
    end
  end

  defp do_validate([regex | tail], string, regexs, path) do
    if Regex.match?(regex, string) do
      do_validate(tail, string, regexs, path)
    else
      render_error(:match, regexs.should_not_match_message, string, Regex.source(regex), path)
    end
  end

  defp render_error(_type, message, string, regex, path) when is_function(message),
    do: message.(string, regex, path)

  defp render_error(type, message, string, regex, path) do
    {
      :error,
      [
        {
          %{
            description: build_message(type, message, regex),
            params: %{
              value: string,
              pattern: regex
            },
            raw_description: build_raw_message(type, message, regex),
            rule: :regexs
          },
          path
        }
      ]
    }
  end

  defp build_message(:match, nil, regex),
    do: "String does not match pattern '#{regex}'"

  defp build_message(:not, nil, regex),
    do: "String matches pattern '#{regex}' but it should not"

  defp build_message(_type, message, _regex),
    do: message

  defp build_raw_message(:match, nil, _regex),
    do: "String does not match pattern '%{pattern}'"

  defp build_raw_message(:not, nil, _regex),
    do: "String matches pattern '%{pattern}' but it should not"

  defp build_raw_message(_type, message, _regex),
    do: message
end
