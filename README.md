# testbldr

[![Package Version](https://img.shields.io/hexpm/v/testbldr)](https://hex.pm/packages/testbldr)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/testbldr/)

This library is a dead simple set of utilities for building test suites programatically.
Most of the time it makes sense to have one test signature per test, and have those tests
automatically discovered and run.
Other times you may want to read test cases in from files, json responses, etc. 
This library is for the second case.

```gleam
import testbldr
import testbldr/should
import gleam/list
import gleam/int
import gleam/json
import gleam/dynamic

pub fn main() {

  // Lets say you have some test
  // cases in a json file. Here's an example of building a test suite
  // from them

  // The function we're testing
  let double = fn(x) { x * 2 }

  // Test cases given as json
  let test_cases =
    "[
    {
        \"name\": \"1 doubled is 2\",
        \"input\": 1,
        \"expected_output\": 2
    },
    {
        \"name\": \"3 doubled is 6\",
        \"input\": 3,
        \"expected_output\": 6
    }
  ]"

  testbldr.demonstrate(
    that: "Our doubling function works",
    with: 
    {
      // Decode our tests cases from the JSON. If it doesn't decode
      // correctly we crash the whole thing because it's a test suite
      let assert Ok(test_cases) = test_cases_from_json(test_cases)

      // Map over our tests cases to start transforming them
      use test_case <- list.map(test_cases)

      // Give each test the name specified in the json, to be printed
      // properly on test run
      use <- testbldr.named(test_case.name)

      // The thing we're actually testing
      double(test_case.input)
      |> should.equal(test_case.expected_output)
    },
  )
}

/// Something to parse our JSON test cases into
type TestCase {
  TestCase(name: String, input: Int, expected_output: Int)
}

/// Decode our list of test cases
fn test_cases_from_json(
  input: String,
) -> Result(List(TestCase), json.DecodeError) {
  let test_decoder =
    dynamic.decode3(
      TestCase,
      dynamic.field("name", of: dynamic.string),
      dynamic.field("input", of: dynamic.int),
      dynamic.field("expected_output", of: dynamic.int),
    )

  json.decode(from: input, using: dynamic.list(test_decoder))
}
```
