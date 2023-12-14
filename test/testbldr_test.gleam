import testbldr
import testbldr/should
import testbldr/pieces
import gleam/list
import gleam/int
import gleam/json
import gleam/dynamic
import gleam/string
import gleam/result

pub fn main() {
  // Basic example of programatically building a test case
  testbldr.demonstrate(that: "Some numbers are odd", with: {
    use n <- list.map([1, 3, 5, 7, 9])
    use <- testbldr.named(int.to_string(n) <> " is odd")
    n % 2
    |> should.equal(1)
  })

  // Lets do a more real world example. Lets say you have some test
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

  testbldr.demonstrate(that: "Our doubling function works", with: {
    let assert Ok(test_cases) = test_cases_from_json(test_cases)

    // Map over our tests cases to start transforming them
    use test_case <- list.map(test_cases)

    // Give each test the name specified in the json, to be printed
    // properly on test run
    use <- testbldr.named(test_case.name)

    // The thing we're actually testing
    double(test_case.input)
    |> should.equal(test_case.expected_output)
  })

  testbldr.demonstrate(that: "Boolean messages look right", with: {
    use val <- list.map([True, False])
    use <- testbldr.named(string.inspect(val) <> " should be true")
    val
    |> should.be_true
  })

  testbldr.demonstrate(that: "Boolean messages look right", with: {
    use val <- list.map([True, False])
    use <- testbldr.named(string.inspect(val) <> " should be false")
    val
    |> should.be_false
  })

  testbldr.demonstrate(that: "Result messages look right", with: {
    use val <- list.map([Ok(Nil), Error(Nil)])
    use <- testbldr.named(string.inspect(val) <> " should be ok")
    val
    |> should.be_ok
  })

  testbldr.demonstrate(that: "Silent tests don't print", with: {
    use val <- list.map([Ok(Nil), Error(Nil)])
    use <- testbldr.named(string.inspect(val) <> " should be ok")
    case result.is_ok(val) {
      True -> pieces.Silent
      False -> pieces.Fail("failed")
    }
  })
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
