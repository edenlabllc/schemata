defmodule Schemata.JsonSchema.SchemaTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Schemata.JsonSchema.Schema
  alias Schemata.JsonSchema.Schema.Root
  alias Schemata.JsonSchema.Validator

  test "resolves local references with escaped and percent-encoded property names" do
    schema =
      Schema.resolve(%{
        "definitions" => %{"a/b~c d" => %{"type" => "integer"}},
        "properties" => %{"value" => %{"$ref" => "#/definitions/a~1b~0c%20d"}}
      })

    ref = schema.schema["properties"]["value"]["$ref"]

    assert ref == [:root, "definitions", "a/b~c d"]
    assert Schema.get_ref_schema(schema, ref) == %{"type" => "integer"}
    assert :ok = Validator.validate(schema, %{"value" => 2})

    assert {:error, [{%{rule: :cast}, "$.value"}]} =
             Validator.validate(schema, %{"value" => "2"})
  end

  test "resolves an existing root and preserves its location and cached references" do
    url = "https://schemas.example.test/integer.json"

    root = %Root{
      schema: %{"$ref" => url},
      refs: %{url => %{"type" => "integer"}},
      location: "https://schemas.example.test/root.json"
    }

    resolved = Schema.resolve(root)

    assert resolved.location == root.location
    assert resolved.refs == root.refs
    assert Schema.get_ref_schema(resolved, resolved.schema["$ref"]) == %{"type" => "integer"}
    assert :ok = Validator.validate(resolved, 7)
    assert {:error, [{%{rule: :cast}, "$"}]} = Validator.validate(resolved, "7")
  end

  test "resolving a root without references preserves its resolved schema" do
    root = Schema.resolve(%{"type" => "object", "additionalProperties" => false})

    assert Schema.resolve(root) == root
  end

  test "rejects invalid schemas against the draft 4 meta-schema" do
    assert_raise Schema.InvalidSchemaError,
                 "schema did not pass validation against its meta-schema:\n* type mismatch. Expected object but got string (at $.properties)",
                 fn -> Schema.resolve(%{"properties" => "invalid"}) end
  end

  test "rejects unsupported drafts" do
    assert_raise Schema.UnsupportedSchemaVersionError, fn ->
      Schema.resolve(%{"$schema" => "http://json-schema.org/draft-07/schema#"})
    end
  end

  test "reports missing local references" do
    assert_raise Schema.InvalidSchemaError,
                 "reference $.definitions.missing could not be resolved",
                 fn ->
                   Schema.resolve(%{"$ref" => "#/definitions/missing"})
                 end
  end

  test "keeps adjacent array indexes in nested validation paths" do
    schema = %{
      "type" => "array",
      "items" => %{
        "type" => "object",
        "properties" => %{
          "values" => %{
            "type" => "array",
            "items" => %{
              "type" => "array",
              "items" => %{"type" => "integer"}
            }
          }
        }
      }
    }

    assert {:error, [{%{rule: :cast}, "$[0].values[0][1]"}]} =
             Validator.validate(schema, [%{"values" => [[1, "2"]]}])
  end

  test "validates decimal multiples without floating-point remainder errors" do
    schema = %{"type" => "number", "multipleOf" => 0.01}

    assert :ok = Validator.validate(schema, 0.03)
    assert :ok = Validator.validate(schema, 0)

    assert {:error, [{%{rule: :number, params: %{multiple_of: 0.01, actual: 0.031}}, "$"}]} =
             Validator.validate(schema, 0.031)
  end
end

defmodule Schemata.JsonSchema.RemoteSchemaTest do
  @moduledoc false

  use ExUnit.Case

  alias Schemata.JsonSchema.Schema
  alias Schemata.JsonSchema.Validator

  @remote_url "https://schemas.example.test/integer.json"

  setup do
    original_config = Application.fetch_env(:schemata, :remote_schema_resolver)

    on_exit(fn ->
      case original_config do
        {:ok, resolver} -> Application.put_env(:schemata, :remote_schema_resolver, resolver)
        :error -> Application.delete_env(:schemata, :remote_schema_resolver)
      end
    end)

    Application.delete_env(:schemata, :remote_schema_resolver)

    :ok
  end

  def resolve_integer_schema(@remote_url), do: %{"type" => "integer"}

  test "uses a function resolver and fetches repeated remote references once" do
    test_pid = self()

    Application.put_env(:schemata, :remote_schema_resolver, fn url ->
      send(test_pid, {:resolved, url})
      %{"type" => "integer"}
    end)

    schema =
      Schema.resolve(%{
        "properties" => %{
          "first" => %{"$ref" => @remote_url},
          "second" => %{"$ref" => @remote_url}
        }
      })

    assert_receive {:resolved, @remote_url}
    refute_receive {:resolved, _}
    assert schema.refs == %{@remote_url => %{"type" => "integer"}}
    assert :ok = Validator.validate(schema, %{"first" => 1, "second" => 2})
  end

  test "uses a resolver configured as a module and function" do
    Application.put_env(:schemata, :remote_schema_resolver, {__MODULE__, :resolve_integer_schema})

    schema = Schema.resolve(%{"$ref" => @remote_url})

    assert schema.refs == %{@remote_url => %{"type" => "integer"}}
    assert :ok = Validator.validate(schema, 1)
  end

  test "raises when a remote reference has no configured resolver" do
    assert_raise Schema.UndefinedRemoteSchemaResolverError, fn ->
      Schema.resolve(%{"$ref" => @remote_url})
    end
  end
end
