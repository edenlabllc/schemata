defmodule Schemata.Validators.EqualsTest do
  @moduledoc false

  use ExUnit.Case
  use Schemata

  describe "validate callbacks" do
    test "array" do
      assert :ok ==
               %Schema{properties: %{foo: array(string(), [equals(~w(a b))])}}
               |> SchemaValidator.validate(%{"foo" => ["a", "b"]})

      assert {:error, "invalid value"} ==
               %Schema{
                 properties: %{foo: array(string(), [equals(~w(a b), {:error, "invalid value"})])}
               }
               |> SchemaValidator.validate(%{"foo" => ["a"]})

      assert :ok ==
               %Schema{properties: %{foo: array([string(), number()], [equals(["bar", 100])])}}
               |> SchemaValidator.validate(%{"foo" => ["bar", 100]})

      assert {:error, "invalid value"} ==
               %Schema{
                 properties: %{
                   foo:
                     array([string(), number()], [equals(["bar", 100], {:error, "invalid value"})])
                 }
               }
               |> SchemaValidator.validate(%{"foo" => ["bar", 50]})
    end

    test "boolean" do
      assert :ok ==
               %Schema{properties: %{foo: boolean([equals(false)])}}
               |> SchemaValidator.validate(%{"foo" => false})

      assert {:error, "invalid value"} ==
               %Schema{properties: %{foo: boolean([equals(false, {:error, "invalid value"})])}}
               |> SchemaValidator.validate(%{"foo" => true})
    end

    test "date" do
      assert :ok ==
               %Schema{properties: %{foo: date([equals("2016-01-01")])}}
               |> SchemaValidator.validate(%{"foo" => "2016-01-01"})

      assert {:error, "invalid value"} ==
               %Schema{
                 properties: %{foo: date([equals("2016-01-01", {:error, "invalid value"})])}
               }
               |> SchemaValidator.validate(%{"foo" => "2015-01-01"})
    end

    test "datetime" do
      assert :ok ==
               %Schema{properties: %{foo: datetime([equals("2016-01-01T00:00:00Z")])}}
               |> SchemaValidator.validate(%{"foo" => "2016-01-01T00:00:00Z"})

      assert {:error, "invalid value"} ==
               %Schema{
                 properties: %{
                   foo: datetime([equals("2016-01-01T00:00:00Z", {:error, "invalid value"})])
                 }
               }
               |> SchemaValidator.validate(%{"foo" => "2016-01-01T00:00:01Z"})
    end

    test "enum" do
      assert :ok ==
               %Schema{properties: %{foo: enum(["bar"], [equals("bar")])}}
               |> SchemaValidator.validate(%{"foo" => "bar"})

      assert {:error, "invalid value"} ==
               %Schema{
                 properties: %{
                   foo: enum(["bar", "baz"], [equals("bar", {:error, "invalid value"})])
                 }
               }
               |> SchemaValidator.validate(%{"foo" => "baz"})
    end

    test "hostname" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{properties: %{foo: hostname([equals("example.local")])}},
                 %{"foo" => "example.local"}
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo: hostname([equals("example.local", {:error, "invalid value"})])
                   }
                 },
                 %{"foo" => "example.localhost"}
               )
    end

    test "number" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{properties: %{foo: number([equals(100)])}},
                 %{"foo" => 100}
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo: number([equals(100, {:error, "invalid value"})])
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
                     foo: object(%{bar: string()}, [], [equals(%{"bar" => "baz"})])
                   }
                 },
                 %{"foo" => %{"bar" => "baz"}}
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo:
                       object(%{bar: string()}, [], [
                         equals(%{"bar" => "baz"}, {:error, "invalid value"})
                       ])
                   }
                 },
                 %{"foo" => %{"bar" => "ba"}}
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
                     foo: ref("id", [equals("1")])
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
                     foo: ref("id", [equals("1", {:error, "invalid value"})])
                   }
                 },
                 %{"foo" => "2"}
               )
    end

    test "string" do
      assert :ok ==
               SchemaValidator.validate(%Schema{properties: %{foo: string([equals("bar")])}}, %{
                 "foo" => "bar"
               })

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{properties: %{foo: string([equals("bar", {:error, "invalid value"})])}},
                 %{"foo" => "baz"}
               )
    end

    test "regex" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{properties: %{foo: regex("[abc]", [equals("a")])}},
                 %{"foo" => "a"}
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo: regex("[abc]", [equals("a", {:error, "invalid value"})])
                   }
                 },
                 %{"foo" => "b"}
               )
    end

    test "time" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{properties: %{foo: time([equals("00:00:00")])}},
                 %{"foo" => "00:00:00"}
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo: time([equals("00:00:00", {:error, "invalid value"})])
                   }
                 },
                 %{"foo" => "00:00:01"}
               )
    end

    test "uuid" do
      assert :ok ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{foo: uuid([equals("c3b29b3d-2506-4a57-b901-2c36159728bf")])}
                 },
                 %{"foo" => "c3b29b3d-2506-4a57-b901-2c36159728bf"}
               )

      assert {:error, "invalid value"} ==
               SchemaValidator.validate(
                 %Schema{
                   properties: %{
                     foo:
                       uuid([
                         equals("c3b29b3d-2506-4a57-b901-2c36159728bf", {:error, "invalid value"})
                       ])
                   }
                 },
                 %{"foo" => "7303f4b6-df53-422e-8d87-eb6df70890b4"}
               )
    end
  end
end
