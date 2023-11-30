import testbldr/pieces
import gleam/string

pub fn equal(a, b) -> pieces.TestOutcome {
  case a == b {
    True -> pieces.Pass
    False -> pieces.Fail(bin_op_msg(a, "==", b))
  }
}

pub fn not_equal(a, b) -> pieces.TestOutcome {
  case a != b {
    True -> pieces.Pass
    False -> pieces.Fail(bin_op_msg(a, "!=", b))
  }
}

pub fn be_true(a: Bool) -> pieces.TestOutcome {
  case a {
    True -> pieces.Pass
    False -> pieces.Fail("\nExpected True, got False\n")
  }
}

pub fn be_false(a: Bool) -> pieces.TestOutcome {
  case a {
    False -> pieces.Pass
    True -> pieces.Fail("\nExpected False, got True\n")
  }
}

pub fn be_ok(a: Result(a, b)) -> pieces.TestOutcome {
  case a {
    Ok(_) -> pieces.Pass
    Error(_) ->
      pieces.Fail("\nExpected Ok, Got Error: " <> string.inspect(a) <> "\n")
  }
}

pub fn be_error(a: Result(a, b)) -> pieces.TestOutcome {
  case a {
    Ok(_) ->
      pieces.Fail("\nExpected Error, Got Ok: " <> string.inspect(a) <> "\n")
    Error(_) -> pieces.Pass
  }
}

fn bin_op_msg(lhs: a, op: String, rhs: b) -> String {
  "\nlhs: " <> string.inspect(lhs) <> "\nrhs: " <> string.inspect(rhs) <> "\nassertion lhs " <> op <> " rhs failed\n"
}
