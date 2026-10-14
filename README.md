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

`Schemata.SchemaValidator.validate/2` validates a `Schemata.Schema` and runs its
custom callbacks, returning `:ok` or `{:error, errors}`.

The engine under `Schemata.JsonSchema` is derived from
[`ex_json_schema`](https://github.com/jonasschmidt/ex_json_schema).
Its original MIT notice is preserved in the [source header](lib/json_schema.ex).

Remote `$ref` resolution requires a resolver that returns a decoded schema map.
Configure it as a function of one argument or a `{module, function}` tuple:

```elixir
config :schemata, :remote_schema_resolver, {MyApp.SchemaResolver, :resolve}
```
