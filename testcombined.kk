// Test suite for combined effects patterns
// Includes both implementation and tests in one file for simplicity

// ========== FUNCTIONS TO TEST ==========

// State management with local variables
fun stateful-computation() : <console,local<_>> int
  var state := 0
  fun increment() : <local<_>,console> ()
    state := state + 1
    println("State incremented to: " ++ state.show)
  
  fun get-state() : <local<_>> int
    state
  
  increment()
  increment()
  increment()
  get-state()

// Logging pattern
fun logged-operation(x : int, y : int) : console int
  println("Log: Starting operation with " ++ x.show ++ " and " ++ y.show)
  val result = x + y
  println("Log: Operation result: " ++ result.show)
  result

// Exception handling with maybe
fun safe-operation(x : int, y : int) : console (maybe<int>)
  println("Attempting safe operation...")
  if y == 0 then
    println("Error: Division by zero")
    Nothing
  else
    val result = x / y
    println("Success: " ++ result.show)
    Just(result)

// Reader pattern (dependency injection simulation)
fun compute-with-config(multiplier : int, values : list<int>) : list<int>
  values.map fn(x)
    x * multiplier

// ========== TEST FRAMEWORK ==========

// Test result type
type test-result
  Pass(name : string)
  Fail(name : string, reason : string)

// Assert functions
fun assert-equal(actual : a, expected : a, msg : string = "", ?(==) : (a,a) -> bool, ?show : (a) -> string) : <console,exn> ()
  if actual == expected then
    println("  ✓ " ++ (if msg == "" then "assertion" else msg))
  else
    val error = "Expected: " ++ expected.show ++ ", Actual: " ++ actual.show
    println("  ✗ " ++ (if msg == "" then "assertion" else msg) ++ " - " ++ error)
    throw(error)

fun assert-true(condition : bool, msg : string = "") : <console,exn> ()
  if condition then
    println("  ✓ " ++ (if msg == "" then "condition" else msg))
  else
    println("  ✗ " ++ (if msg == "" then "condition" else msg))
    throw("Condition was false")

fun assert-false(condition : bool, msg : string = "") : <console,exn> ()
  assert-true(!condition, msg)

// ========== TEST CASES ==========

// Test stateful computation
fun test-stateful() : <console,local<_>,exn> test-result
  println("\nTesting: Stateful Computation")
  val result = stateful-computation()
  assert-equal(result, 3, "Final state should be 3")
  
  // Additional state test
  var counter := 0
  fun inc() : <local<_>> ()
    counter := counter + 1
  
  inc()
  assert-equal(counter, 1, "Counter after first increment")
  inc()
  assert-equal(counter, 2, "Counter after second increment")
  
  Pass("Stateful Computation")

// Test logged operations
fun test-logged() : <console,exn> test-result
  println("\nTesting: Logged Operations")
  assert-equal(logged-operation(5, 3), 8, "5 + 3 = 8")
  assert-equal(logged-operation(10, -5), 5, "10 + (-5) = 5")
  assert-equal(logged-operation(0, 0), 0, "0 + 0 = 0")
  assert-equal(logged-operation(-7, -3), -10, "(-7) + (-3) = -10")
  
  Pass("Logged Operations")

// Test safe operations with maybe
fun test-safe() : <console,exn> test-result
  println("\nTesting: Safe Operations")
  // Test successful division
  match safe-operation(10, 2)
    Just(v) -> assert-equal(v, 5, "10 / 2 = 5")
    Nothing -> throw("Should succeed for valid division")
  
  // Test division by zero
  match safe-operation(10, 0)
    Just(_) -> throw("Should fail for division by zero")
    Nothing -> assert-true(True, "Division by zero returns Nothing")
  
  // Test negative numbers
  match safe-operation(-10, 2)
    Just(v) -> assert-equal(v, -5, "-10 / 2 = -5")
    Nothing -> throw("Should succeed for negative division")
  
  // Test when dividend is zero
  match safe-operation(0, 5)
    Just(v) -> assert-equal(v, 0, "0 / 5 = 0")
    Nothing -> throw("Should succeed when dividend is zero")
  
  Pass("Safe Operations")

// Test reader pattern
fun test-reader() : <console,exn> test-result
  println("\nTesting: Reader Pattern")
  assert-equal(
      compute-with-config(2, [1, 2, 3]),
      [2, 4, 6],
      "Multiply [1,2,3] by 2"
    )
  
  assert-equal(
      compute-with-config(0, [1, 2, 3]),
      [0, 0, 0],
      "Multiply by 0"
    )
  
  assert-equal(
      compute-with-config(-1, [5, 10]),
      [-5, -10],
      "Multiply by -1"
    )
  
  assert-equal(
      compute-with-config(10, []),
      [],
      "Empty list"
    )
  
  assert-equal(
      compute-with-config(3, [7]),
      [21],
      "Single element"
    )
  
  Pass("Reader Pattern")

// Test combination of operations
fun test-combination() : <console,local<_>,div,exn> test-result
  println("\nTesting: Combined Operations")
  // Chain operations together
  val state-result = stateful-computation()
  val logged-result = logged-operation(state-result, 7)
  val config-result = compute-with-config(2, [logged-result])
  
  assert-equal(state-result, 3, "State result")
  assert-equal(logged-result, 10, "3 + 7 = 10")
  assert-equal(config-result, [20], "[10] * 2 = [20]")
  
  // Test safe operation chain
  match safe-operation(100, 10)
    Just(v1) ->
      match safe-operation(v1, 2)
        Just(v2) -> assert-equal(v2, 5, "100/10/2 = 5")
        Nothing -> throw("Second division should succeed")
    Nothing -> throw("First division should succeed")
  
  Pass("Combined Operations")

// Test edge cases
fun test-edge-cases() : <console,exn> test-result
  println("\nTesting: Edge Cases")
  // Large numbers
  assert-equal(
    logged-operation(1000000, 1000000),
    2000000,
    "Large number addition"
  )
  
  // Maximum safe division
  match safe-operation(2147483647, 1)
    Just(v) -> assert-equal(v, 2147483647, "Max int division")
    Nothing -> throw("Should handle max int")
  
  // Empty and single element lists
  assert-equal(
    compute-with-config(100, []),
    [],
    "Empty list with large multiplier"
  )
  
  assert-equal(
    compute-with-config(0, [100, 200, 300]),
    [0, 0, 0],
    "Zero multiplier"
  )
  
  Pass("Edge Cases")

// ========== TEST RUNNER ==========

fun run-tests() : <console,local<_>,div,exn> ()
  println("\n" ++ "============================================================")
  println("COMBINED EFFECTS TEST SUITE")
  println("============================================================")
  
  val tests = [
    test-stateful,
    test-logged,
    test-safe,
    test-reader,
    test-combination,
    test-edge-cases
  ]
  
  var passed := 0
  var failed := 0
  val results = []
  
  tests.foreach fn(test)
    match test()
      Pass(name) ->
        passed := passed + 1
        println("✅ PASS: " ++ name)
      Fail(name, reason) ->
        failed := failed + 1
        println("❌ FAIL: " ++ name ++ " - " ++ reason)
  
  println("\n" ++ "============================================================")
  println("TEST SUMMARY")
  println("============================================================")
  println("Total: " ++ (passed + failed).show)
  println("Passed: " ++ passed.show ++ " (" ++ ((passed * 100) / (passed + failed)).show ++ "%)")
  println("Failed: " ++ failed.show)
  
  if failed == 0 then
    println("\n🎉 ALL TESTS PASSED! 🎉")
  else
    println("\n⚠️  SOME TESTS FAILED")

fun main() : <console,local<_>,div,exn> ()
  run-tests()