import gleam/io
import simplifile
import gleam/list
import glance
import gleam/otp/task
import colours
import gleam/int

/// A test has a name and a body (a function which returns a TestOutcome)
pub type Test =
  #(String, fn() -> TestOutcome)

/// A test can either pass or fail with a given reason
pub type TestOutcome {
  Pass
  Fail(msg: String)
}

/// Let a test pass
pub fn pass() -> TestOutcome {
  Pass
}

/// Let a test fail
pub fn fail(msg: String) -> TestOutcome {
  Fail(msg)
}

/// The list of tests to run
pub type TestSuite =
  List(Test)

/// New test suite is just an empty list
pub const new: TestSuite = []

/// Add a single test to the test suite 
pub fn test(
  input: TestSuite,
  name: String,
  new_test: fn() -> TestOutcome,
) -> TestSuite {
  [#(name, new_test), ..input]
}

/// Add a list of tests to the test suite
pub fn tests(input: TestSuite, new_tests: List(Test)) -> TestSuite {
  list.append(input, new_tests)
}

/// Run the tests and print the test run output
pub fn run(input: TestSuite) {
  io.println("Running tests...\n\n")
  let total_tests = list.length(input)
  let total_passed =
    input
    |> list.map(fn(test) {
      let #(name, test) = test
      #(name, task.async(test))
    })
    |> list.index_fold(
      0,
      fn(acc, test, index) {
        let #(name, test) = test
        case task.try_await_forever(test) {
          Ok(Pass) -> {
            io.print(int.to_string(index + 1) <> ". ")
            { name <> " passed" }
            |> colours.fggreen1
            |> io.println
            acc + 1
          }
          Ok(Fail(msg)) -> {
            io.print(int.to_string(index + 1) <> ". ")
            { name <> " failed: " <> msg }
            |> colours.fgred1
            |> io.println
            acc
          }
          Error(_) -> {
            io.print(int.to_string(index + 1) <> ". ")
            { name <> " panicked!" }
            |> colours.fgred1
            |> io.println
            acc
          }
        }
      },
    )
  let ratio =
    "\n\n" <> int.to_string(total_passed) <> "/" <> int.to_string(total_tests) <> " tests passed"
  case total_passed == total_tests {
    True ->
      ratio
      |> colours.fggreen1
      |> io.println
    False ->
      ratio
      |> colours.fgred1
      |> io.println
  }
}
