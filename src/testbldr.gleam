import gleam/io
import gleam/list
import gleam/int
import gleam/erlang
import gleam_community/ansi
import testbldr/pieces

/// Creates a new test with the given name
pub fn named(name: String, new_test: fn() -> pieces.TestOutcome) -> pieces.Test {
  pieces.Test(name, new_test)
}

/// Run the tests and print the test run output
pub fn demonstrate(with input: List(pieces.Test), that name: String) {
  io.println("\nDemonstrating that: " <> name <> "\n")
  let total_tests = list.length(input)
  let total_passed =
    input
    |> list.index_fold(0, fn(acc, tst, index) {
      let pieces.Test(name, test_function) = tst
      case erlang.rescue(test_function) {
        Ok(pieces.Silent) -> acc + 1
        Ok(pieces.Pass) -> {
          io.print(int.to_string(index + 1) <> ". ")
          { "Test \"" <> name <> "\" passed" }
          |> ansi.green
          |> io.println

          acc + 1
        }
        Ok(pieces.Fail(msg)) -> {
          io.print(int.to_string(index + 1) <> ". ")
          { "Test \"" <> name <> "\" failed: " }
          |> ansi.red
          |> io.println

          msg
          |> io.println

          acc
        }
        Error(_) -> {
          io.print(int.to_string(index + 1) <> ". ")
          { "Test \"" <> name <> "\" panicked!" }
          |> ansi.red
          |> io.println

          acc
        }
      }
    })

  let ratio =
    "\n" <> int.to_string(total_passed) <> "/" <> int.to_string(total_tests) <> " tests passed\n"
  case total_passed == total_tests {
    True ->
      ratio
      |> ansi.green
      |> io.println
    False ->
      ratio
      |> ansi.red
      |> io.println
  }
}
