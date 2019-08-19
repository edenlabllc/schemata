defmodule Schemata.Validators.EqualsTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "validate callbacks" do
    test "array" do
      assert :ok ==
               %Schema{properties: %{foo: array(string(), callbacks: [equals(~w(a b))])}}
               |> SchemaValidator.validate(%{"foo" => ["a", "b"]})

      assert {:error, "invalid value"} ==
               %Schema{
                 properties: %{
                   foo: array(string(), callbacks: [equals(~w(a b), {:error, "invalid value"})])
                 }
               }
               |> SchemaValidator.validate(%{"foo" => ["a"]})

      assert :ok ==
               %Schema{
                 properties: %{
                   foo: array([string(), number()], callbacks: [equals(["bar", 100])])
                 }
               }
               |> SchemaValidator.validate(%{"foo" => ["bar", 100]})

      assert {:error, "invalid value"} ==
               %Schema{
                 properties: %{
                   foo:
                     array([string(), number()],
                       callbacks: [equals(["bar", 100], {:error, "invalid value"})]
                     )
                 }
               }
               |> SchemaValidator.validate(%{"foo" => ["bar", 50]})

      assert :ok ==
               %Schema{properties: %{foo: array(string(), minItems: 0)}}
               |> SchemaValidator.validate(%{"foo" => []})
    end

    test "boolean" do
      assert :ok ==
               %Schema{properties: %{foo: boolean(callbacks: [equals(false)])}}
               |> SchemaValidator.validate(%{"foo" => false})

      assert {:error, "invalid value"} ==
               %Schema{
                 properties: %{
                   foo: boolean(callbacks: [equals(false, {:error, "invalid value"})])
                 }
               }
               |> SchemaValidator.validate(%{"foo" => true})
    end

    test "date" do
      assert :ok ==
               %Schema{properties: %{foo: date(callbacks: [equals("2016-01-01")])}}
               |> SchemaValidator.validate(%{"foo" => "2016-01-01"})

      assert {:error, "invalid value"} ==
               %Schema{
                 properties: %{
                   foo: date(callbacks: [equals("2016-01-01", {:error, "invalid value"})])
                 }
               }
               |> SchemaValidator.validate(%{"foo" => "2015-01-01"})
    end

    test "datetime" do
      assert :ok ==
               %Schema{properties: %{foo: datetime(callbacks: [equals("2016-01-01T00:00:00Z")])}}
               |> SchemaValidator.validate(%{"foo" => "2016-01-01T00:00:00Z"})

      assert {:error, "invalid value"} ==
               %Schema{
                 properties: %{
                   foo:
                     datetime(
                       callbacks: [equals("2016-01-01T00:00:00Z", {:error, "invalid value"})]
                     )
                 }
               }
               |> SchemaValidator.validate(%{"foo" => "2016-01-01T00:00:01Z"})
    end

    test "enum" do
      assert :ok ==
               %Schema{properties: %{foo: enum(["bar"], callbacks: [equals("bar")])}}
               |> SchemaValidator.validate(%{"foo" => "bar"})

      assert {:error, "invalid value"} ==
               %Schema{
                 properties: %{
                   foo:
                     enum(["bar", "baz"], callbacks: [equals("bar", {:error, "invalid value"})])
                 }
               }
               |> SchemaValidator.validate(%{"foo" => "baz"})
    end

    test "hostname" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{properties: %{foo: hostname(callbacks: [equals("example.local")])}},
                 %{"foo" => "example.local"}
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo:
                       hostname(callbacks: [equals("example.local", {:error, "invalid value"})])
                   }
                 },
                 %{"foo" => "example.localhost"}
               )
    end

    test "number" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{properties: %{foo: number(callbacks: [equals(100)])}},
                 %{"foo" => 100}
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo: number(callbacks: [equals(100, {:error, "invalid value"})])
                   }
                 },
                 %{"foo" => 50}
               )
    end

    test "object" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo: object(%{bar: string()}, callbacks: [equals(%{"bar" => "baz"})])
                   }
                 },
                 %{"foo" => %{"bar" => "baz"}}
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo:
                       object(%{bar: string()},
                         callbacks: [
                           equals(%{"bar" => "baz"}, {:error, "invalid value"})
                         ]
                       )
                   }
                 },
                 %{"foo" => %{"bar" => "ba"}}
               )

      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo: object(%{bar: string()})
                   }
                 },
                 %{"foo" => %{"bar" => "baz"}}
               )
    end

    test "ref" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   definitions: %{
                     id: string()
                   },
                   properties: %{
                     foo: ref("id", callbacks: [equals("1")])
                   }
                 },
                 %{"foo" => "1"}
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   definitions: %{
                     id: string()
                   },
                   properties: %{
                     foo: ref("id", callbacks: [equals("1", {:error, "invalid value"})])
                   }
                 },
                 %{"foo" => "2"}
               )
    end

    test "string" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{properties: %{foo: string(callbacks: [equals("bar")])}},
                 %{
                   "foo" => "bar"
                 }
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo: string(callbacks: [equals("bar", {:error, "invalid value"})])
                   }
                 },
                 %{"foo" => "baz"}
               )
    end

    test "regex" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{properties: %{foo: regex("[abc]", callbacks: [equals("a")])}},
                 %{"foo" => "a"}
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo: regex("[abc]", callbacks: [equals("a", {:error, "invalid value"})])
                   }
                 },
                 %{"foo" => "b"}
               )
    end

    test "time" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{properties: %{foo: time(callbacks: [equals("00:00:00")])}},
                 %{"foo" => "00:00:00"}
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo: time(callbacks: [equals("00:00:00", {:error, "invalid value"})])
                   }
                 },
                 %{"foo" => "00:00:01"}
               )
    end

    test "uuid" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo: uuid(callbacks: [equals("c3b29b3d-2506-4a57-b901-2c36159728bf")])
                   }
                 },
                 %{"foo" => "c3b29b3d-2506-4a57-b901-2c36159728bf"}
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo:
                       uuid(
                         callbacks: [
                           equals(
                             "c3b29b3d-2506-4a57-b901-2c36159728bf",
                             {:error, "invalid value"}
                           )
                         ]
                       )
                   }
                 },
                 %{"foo" => "7303f4b6-df53-422e-8d87-eb6df70890b4"}
               )
    end
  end
end
