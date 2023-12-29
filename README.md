# testbldr

[![Package Version](https://img.shields.io/hexpm/v/testbldr)](https://hex.pm/packages/testbldr)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/testbldr/)

This library is a dead simple set of utilities for building test suites programatically.
Most of the time it makes sense to have one test signature per test, and have those tests
automatically discovered and run.
Other times you may want to read test cases in from files, json responses, etc. 
This library is for the second case.

# Example

```gleam
import testbldr
import gleam/list
import gleam/int

pub fn main() {
  let test_runner =
    testbldr.test_runner_default()
    |> testbldr.include_passing_tests_in_output(True)
    |> testbldr.output_results_to_stdout()

  let tests = {
    use n <- list.map([1, 3, 5, 8, 9])
    use <- testbldr.named(int.to_string(n) <> " is odd")
    case n % 2 == 1 {
      True -> testbldr.Pass
      False -> testbldr.Fail(int.to_string(n) <> " is even, not odd")
    }
  }

  test_runner
  |> testbldr.run(tests)
}
```
