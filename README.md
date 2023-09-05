# testbldr

[![Package Version](https://img.shields.io/hexpm/v/testbldr)](https://hex.pm/packages/testbldr)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/testbldr/)

This library is a dead simple set of utilities for building test suites programatically.
Most of the time it makes sense to have one test signature per test, nad have those tests
automatically discovered and run.
Other times you may want to read test cases in from files, json responses, etc. 
This library is for the second case.

```gleam
import testbldr

pub fn main() {
    testbldr.new
    |> testbldr.tests(one_is_a_small_number())
    |> testbldr.run
}

fn one_is_a_small_number() -> List(testbldr.Test) {
  use number <- list.map(list.range(2, 10))
  let name = "One is less than " <> int.to_string(number)
  let test = fn() {
    case 1 < number {
      True -> testbldr.pass()
      False -> testbldr.fail("Shockingly 1 >" <> int.to_string(number))
    }
  }
  #(name, test)
}
```
