//// A collection of assertion functions for use in tests, similar to gleeunit's `should` module.

import testbldr
import gleam/string

pub fn equal(a, b) -> testbldr.TestOutcome {
  case a == b {
    True -> testbldr.Pass
    False -> testbldr.Fail(bin_op_msg(a, "==", b))
  }
}

pub fn not_equal(a, b) -> testbldr.TestOutcome {
  case a != b {
    True -> testbldr.Pass
    False -> testbldr.Fail(bin_op_msg(a, "!=", b))
  }
}

pub fn be_true(a: Bool) -> testbldr.TestOutcome {
  case a {
    True -> testbldr.Pass
    False -> testbldr.Fail("\nExpected True, got False\n")
  }
}

pub fn be_false(a: Bool) -> testbldr.TestOutcome {
  case a {
    False -> testbldr.Pass
    True -> testbldr.Fail("\nExpected False, got True\n")
  }
}

pub fn be_ok(a: Result(a, b)) -> testbldr.TestOutcome {
  case a {
    Ok(_) -> testbldr.Pass
    Error(_) ->
      testbldr.Fail("\nExpected Ok, Got Error: " <> string.inspect(a) <> "\n")
  }
}

pub fn be_error(a: Result(a, b)) -> testbldr.TestOutcome {
  case a {
    Ok(_) ->
      testbldr.Fail("\nExpected Error, Got Ok: " <> string.inspect(a) <> "\n")
    Error(_) -> testbldr.Pass
  }
}

fn bin_op_msg(lhs: a, op: String, rhs: b) -> String {
  "\nlhs: "
  <> string.inspect(lhs)
  <> "\nrhs: "
  <> string.inspect(rhs)
  <> "\nassertion lhs "
  <> op
  <> " rhs failed\n"
}
