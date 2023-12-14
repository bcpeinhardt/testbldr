/// A test has a name and a body (a function which returns a TestOutcome)
pub type Test {
  Test(name: String, test_function: fn() -> TestOutcome)
}

/// A test can either pass or fail with a given reason
pub type TestOutcome {
  Pass
  Silent
  Fail(msg: String)
}
