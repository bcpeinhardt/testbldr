import testbldr/pieces
import gleam/string

pub fn equal(a, b) -> pieces.TestOutcome {
  case a == b {
    True -> pieces.Pass
    False -> pieces.Fail(string.inspect(a) <> " != " <> string.inspect(b))
  }
}

pub fn not_equal(a, b) -> pieces.TestOutcome {
  case a != b {
    True -> pieces.Pass
    False -> pieces.Fail(string.inspect(a) <> " == " <> string.inspect(b))
  }
}
