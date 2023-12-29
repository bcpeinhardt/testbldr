import gleam/io
import gleam/list
import gleam/int
import gleam/erlang
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import simplifile.{type FileError}

/// A test has a name and a body (a function which returns a TestOutcome)
pub type Test {
  Test(name: String, test_function: fn() -> TestOutcome)
}

/// A test can either pass or fail with a given reason
pub type TestOutcome {
  Pass
  Fail(msg: String)
}

/// Creates a new test with the given name
pub fn named(name: String, new_test: fn() -> TestOutcome) -> Test {
  Test(name, new_test)
}

/// Configuration for how to run a set of tests
pub opaque type TestRunner {
  TestRunner(
    verbosity: Verbosity,
    send_output_to: Set(OutputDestination),
    test_printer: Option(TestOutcomePrinter),
    ratio_printer: Option(fn(Int, Int) -> String),
  )
}

type TestOutcomePrinter =
  fn(String, TestOutcome) -> String

/// Create a new test runner with the default configuration
pub fn test_runner_default() -> TestRunner {
  TestRunner(
    Normal,
    set.from_list([Stdout]),
    Some(outcome_to_string),
    Some(ratio_to_string),
  )
}

/// Set whether to include passing tests in the output
pub fn include_passing_tests_in_output(
  runner: TestRunner,
  input: Bool,
) -> TestRunner {
  let verbosity = case input {
    True -> Verbose
    False -> Normal
  }
  TestRunner(..runner, verbosity: verbosity)
}

/// Write the test run output to a file
pub fn output_results_to_file(
  runner: TestRunner,
  path path: String,
) -> TestRunner {
  TestRunner(
    ..runner,
    send_output_to: set.insert(runner.send_output_to, File(path)),
  )
}

/// Write the test run output to stdout
pub fn output_results_to_stdout(runner: TestRunner) -> TestRunner {
  TestRunner(
    ..runner,
    send_output_to: set.insert(runner.send_output_to, Stdout),
  )
}

/// How to print an individual test outcome
pub fn display_test_outcome_using(
  runner: TestRunner,
  printer printer: fn(String, TestOutcome) -> String,
) -> TestRunner {
  TestRunner(..runner, test_printer: Some(printer))
}

/// How to print the ratio of passing to failing tests
pub fn display_ratio_using(
  runner: TestRunner,
  printer printer: fn(Int, Int) -> String,
) -> TestRunner {
  TestRunner(..runner, ratio_printer: Some(printer))
}

/// Set the verbosity for the test run output
type Verbosity {
  Normal
  Verbose
}

/// Set where to write the test run output
type OutputDestination {
  Stdout
  File(path: String)
}

type TestStats {
  TestStats(
    total_tests: Int,
    total_passed: Int,
    total_failed: Int,
    total_panicked: Int,
    inner: List(#(String, TestOutcome)),
  )
}

/// Runs a list of tests with the provided test runner
pub fn run(runner: TestRunner, tests: List(Test)) {
  let test_stats = {
    use acc, Test(name, test_function) <- list.fold(
      tests,
      TestStats(0, 0, 0, 0, []),
    )
    case erlang.rescue(test_function) {
      Ok(Pass) -> {
        TestStats(
          acc.total_tests + 1,
          acc.total_passed + 1,
          acc.total_failed,
          acc.total_panicked,
          [#(name, Pass), ..acc.inner],
        )
      }
      Ok(Fail(msg)) -> {
        TestStats(
          acc.total_tests + 1,
          acc.total_passed,
          acc.total_failed + 1,
          acc.total_panicked,
          [#(name, Fail(msg)), ..acc.inner],
        )
      }
      Error(_) -> {
        TestStats(
          acc.total_tests + 1,
          acc.total_passed,
          acc.total_failed,
          acc.total_panicked + 1,
          [#(name, Fail("Test Panicked!")), ..acc.inner],
        )
      }
    }
  }

  let filter = case runner.verbosity {
    Normal -> fn(x: #(String, TestOutcome)) {
      case x.1 {
        Pass -> False
        Fail(_) -> True
      }
    }
    Verbose -> fn(_) { True }
  }
  let filtered_stats =
    TestStats(..test_stats, inner: list.filter(test_stats.inner, filter))

  {
    use dest <- list.each(set.to_list(runner.send_output_to))
    case dest {
      Stdout -> write_stats_to_stdout(runner, filtered_stats)
      File(path) -> {
        let assert Ok(_) = write_stats_to_file(runner, filtered_stats, path)
        Nil
      }
    }
  }
}

fn write_stats_to_file(
  runner: TestRunner,
  stats: TestStats,
  path: String,
) -> Result(Nil, FileError) {
  let individual = {
    use acc, #(name, outcome) <- list.fold(stats.inner, "")
    case runner.test_printer {
      Some(printer) -> acc <> printer(name, outcome) <> "\n"
      None -> acc
    }
  }

  let ratio = case runner.ratio_printer {
    Some(printer) -> printer(stats.total_passed, stats.total_tests)
    None -> ""
  }

  simplifile.write(individual <> "\n" <> ratio, to: path)
}

fn write_stats_to_stdout(runner: TestRunner, stats: TestStats) {
  {
    use #(name, outcome) <- list.each(stats.inner)
    case runner.test_printer {
      Some(printer) ->
        printer(name, outcome)
        |> io.println
      None -> Nil
    }
  }

  io.println("")

  case runner.ratio_printer {
    Some(printer) ->
      printer(stats.total_passed, stats.total_tests)
      |> io.println
    None -> Nil
  }
}

// The default way to print a test outcome
fn outcome_to_string(name: String, outcome: TestOutcome) -> String {
  case outcome {
    Pass -> "✅ " <> name
    Fail(msg) -> "❌ " <> name <> ": Failed (" <> msg <> ")"
  }
}

// The default way to print the pass/fail ratio for the test suite
fn ratio_to_string(passed: Int, total: Int) -> String {
  let prefix_emoji = case passed == total {
    True -> "✅"
    False -> "❌"
  }
  
  prefix_emoji <> " " <> int.to_string(passed) <> "/" <> int.to_string(total) <> " tests passed"
}
