defmodule Schemata.Validators.PersonName do
  alias Schemata.Validators.Regexs

  def person_name(message \\ nil) do
    Regexs.regexs(
      [
        # all allowed characters
        ~r/^[А-ЩЬЮЯҐЄІЇа-щьюяґєії\s\.\-\/']+$/ui,
        # first character must be a letter
        ~r/^[А-ЩЬЮЯҐЄІЇа-щьюяґєії]/ui,
        # no two or more special characters in a row
        {:not, ~r/[\s\.\-\/']{2,}/ui},
        # no special characters at the end except a dot
        {:not, ~r/[\s\-\/']$/ui}
      ],
      message
    )
  end
end
