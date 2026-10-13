# Schemata

Build JSON Schema draft 4 definitions with Elixir structs and validate data with
custom callbacks.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `schemata` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:schemata, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/schemata](https://hexdocs.pm/schemata).

## JSON Schema validation

`Schemata.SchemaValidator.validate/2` validates a `Schemata.Schema` and then runs
its custom callbacks. It returns `:ok` or `{:error, errors}`. Each JSON Schema
error is a `{details, path}` tuple, where `details` contains `:rule`, `:params`,
`:description`, and `:raw_description`, and `path` starts with `$`.

The draft 4 resolver and validator are maintained in this repository under
`Schemata.JsonSchema`. They were copied from the
[`nex_json_schema2` 0.8.10 Hex release](https://hex.pm/packages/nex_json_schema2/0.8.10),
whose archive SHA-256 is
`8446ccad7becd19978f2e047d74878bb7daf9b4529c864c923ed26223964acf7`.
The original [MIT license](third_party/nex_json_schema2/LICENSE) is preserved and
included in package builds. The separate namespace allows applications to use
other libraries that still depend on `NExJsonSchema` without module conflicts.
Decimal remains a direct dependency for `multipleOf` validation.

Remote `$ref` resolution requires a resolver that returns a decoded schema map.
Configure it as a function of one argument or a `{module, function}` tuple:

```elixir
config :schemata, :remote_schema_resolver, {MyApp.SchemaResolver, :resolve}
```

The existing `:nex_json_schema, :remote_schema_resolver` setting remains a fallback
when no resolver is configured for `:schemata`.

