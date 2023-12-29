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
