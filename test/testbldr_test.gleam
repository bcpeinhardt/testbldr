import gleam/string
import gleam/list
import gleam/int
import testbldr

pub fn main() {
  testbldr.new
  |> testbldr.tests(one_is_a_small_number())
  |> testbldr.test("floating_test", floating)
  |> testbldr.test("should fail", failing)
  |> testbldr.test("should panic", fn() { panic })
  |> testbldr.test(
    "inline",
    fn() {
      case
        "cat"
        |> string.contains("c")
      {
        True -> testbldr.pass()
        False -> testbldr.fail("Cat does not contain a c for some reason")
      }
    },
  )
  |> testbldr.run
}

fn floating() {
  testbldr.pass()
}

fn failing() {
  testbldr.fail("I'm supposed to fail")
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
