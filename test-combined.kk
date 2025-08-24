// Test suite for combined effects patterns
// Note: Since we can't import modules with custom effects easily,
// we'll create simplified test versions of the functions here

// Test helper function for checking values
fun assert-equal(actual : a, expected : a, msg : string = "") : <console,exn> ()
  if actual == expected then
    println("✓ PASS: " ++ (if msg == "" then "assertion" else msg))
  else
    println("✗ FAIL: " ++ (if msg == "" then "assertion" else msg))
    println("  Expected: " ++ expected.show)
    println("  Actual: " ++ actual.show)
    throw("Test failed")

fun assert-true(condition : bool, msg : string = "") : <console,exn> ()
  if condition then
    println("✓ PASS: " ++ (if msg == "" then "assertion" else msg))
  else
    println("✗ FAIL: " ++ (if msg == "" then "assertion" else msg))
    throw("Test failed")

// Test stateful computation
fun test-stateful() : <console,local<_>,exn> ()
  println("\n=== Testing Stateful Computation ===")
  
  val result = stateful-computation()
  assert-equal(result, 3, "stateful-computation should return 3")
  
  // Test that state increments correctly
  var test-state := 0
  fun test-increment() : <local<_>> ()
    test-state := test-state + 1
  
  test-increment()
  assert-equal(test-state, 1, "First increment")
  test-increment()
  assert-equal(test-state, 2, "Second increment")
  test-increment()
  assert-equal(test-state, 3, "Third increment")

// Test logged operation
fun test-logged() : <console,exn> ()
  println("\n=== Testing Logged Operation ===")
  
  val result1 = logged-operation(10, 20)
  assert-equal(result1, 30, "10 + 20 should equal 30")
  
  val result2 = logged-operation(5, -3)
  assert-equal(result2, 2, "5 + (-3) should equal 2")
  
  val result3 = logged-operation(0, 0)
  assert-equal(result3, 0, "0 + 0 should equal 0")

// Test safe operations
fun test-safe-operations() : <console,exn> ()
  println("\n=== Testing Safe Operations ===")
  
  // Test successful division
  match safe-operation(10, 2)
    Just(v) -> assert-equal(v, 5, "10 / 2 should equal 5")
    Nothing -> throw("Should not fail for valid division")
  
  // Test division by zero
  match safe-operation(10, 0)
    Just(_) -> throw("Should fail for division by zero")
    Nothing -> assert-true(True, "Division by zero returns Nothing")
  
  // Test negative division
  match safe-operation(-10, 2)
    Just(v) -> assert-equal(v, -5, "-10 / 2 should equal -5")
    Nothing -> throw("Should not fail for negative division")

// Test reader pattern
fun test-reader-pattern() : <console,exn> ()
  println("\n=== Testing Reader Pattern ===")
  
  val result1 = compute-with-config(2, [1, 2, 3])
  assert-equal(result1, [2, 4, 6], "Multiplier 2 on [1,2,3]")
  
  val result2 = compute-with-config(0, [1, 2, 3])
  assert-equal(result2, [0, 0, 0], "Multiplier 0 on [1,2,3]")
  
  val result3 = compute-with-config(-1, [1, 2, 3])
  assert-equal(result3, [-1, -2, -3], "Multiplier -1 on [1,2,3]")
  
  val result4 = compute-with-config(3, [])
  assert-equal(result4, [], "Empty list should return empty")

// Test transactional update
fun test-transaction() : <console,local<_>,exn> ()
  println("\n=== Testing Transactional Update ===")
  
  // Since transactional-update has internal state, we test its behavior
  val result = transactional-update()
  assert-equal(result, False, "Transaction should rollback when value > 120")
  
  // Test commit scenario (would need to modify the function to be parameterized)
  var test-backup := 100
  var test-current := 100
  
  fun test-commit() : <local<_>> bool
    test-backup := test-current
    True
  
  fun test-rollback() : <local<_>> bool
    test-current := test-backup
    False
  
  test-current := 110
  val commit-result = if test-current <= 120 then test-commit() else test-rollback()
  assert-equal(commit-result, True, "Should commit when value <= 120")
  assert-equal(test-backup, 110, "Backup should be updated after commit")

// Test complex workflow
fun test-complex-workflow() : <console,local<_>,div,exn> ()
  println("\n=== Testing Complex Workflow ===")
  
  val result = complex-workflow()
  assert-equal(result, "Workflow completed successfully", "Workflow should complete successfully")
  
  // Test individual components that make up the workflow
  val state-res = stateful-computation()
  assert-equal(state-res, 3, "State computation in workflow")
  
  val logged-res = logged-operation(3, 10)
  assert-equal(logged-res, 13, "Logged operation in workflow")
  
  match safe-operation(13, 5)
    Just(v) -> assert-equal(v, 2, "Safe division in workflow")
    Nothing -> throw("Safe operation should succeed")

// Test edge cases
fun test-edge-cases() : <console,local<_>,div,exn> ()
  println("\n=== Testing Edge Cases ===")
  
  // Test with maximum integers
  val large-result = logged-operation(1000000, 1000000)
  assert-equal(large-result, 2000000, "Large number addition")
  
  // Test empty list operations
  val empty-config = compute-with-config(10, [])
  assert-equal(empty-config, [], "Config with empty list")
  
  // Test single element list
  val single-config = compute-with-config(5, [7])
  assert-equal(single-config, [35], "Config with single element")

// Integration test
fun test-integration() : <console,local<_>,div,exn> ()
  println("\n=== Integration Test ===")
  
  // Run multiple operations in sequence
  val state1 = stateful-computation()
  val logged1 = logged-operation(state1, 10)
  val config1 = compute-with-config(2, [logged1])
  
  assert-equal(state1, 3, "First state result")
  assert-equal(logged1, 13, "Logged with state result")
  assert-equal(config1, [26], "Config with logged result")
  
  // Test chaining of maybe operations
  match safe-operation(100, 10)
    Just(v1) -> 
      match safe-operation(v1, 2)
        Just(v2) ->
          assert-equal(v2, 5, "Chained safe operations: 100/10/2")
        Nothing -> throw("Second division should succeed")
    Nothing -> throw("First division should succeed")

// Main test runner
fun run-all-tests() : <console,local<_>,div,exn> ()
  println("=" .repeat(50))
  println("RUNNING TEST SUITE FOR COMBINED EFFECTS")
  println("=" .repeat(50))
  
  var passed := 0
  var failed := 0
  
  fun run-test(name : string, test : () -> <console,local<_>,div,exn> ()) : <console,local<_>,div,exn> ()
    try
      test()
      passed := passed + 1
      println("✓ " ++ name ++ " passed")
    catch
      exn ->
        failed := failed + 1
        println("✗ " ++ name ++ " failed: " ++ exn.show)
  
  run-test("Stateful Computation", test-stateful)
  run-test("Logged Operation", test-logged)
  run-test("Safe Operations", test-safe-operations)
  run-test("Reader Pattern", test-reader-pattern)
  run-test("Transaction", test-transaction)
  run-test("Complex Workflow", test-complex-workflow)
  run-test("Edge Cases", test-edge-cases)
  run-test("Integration", test-integration)
  
  println("\n" ++ "=" .repeat(50))
  println("TEST RESULTS")
  println("=" .repeat(50))
  println("Passed: " ++ passed.show ++ " / " ++ (passed + failed).show)
  println("Failed: " ++ failed.show ++ " / " ++ (passed + failed).show)
  
  if failed > 0 then
    println("\n❌ TEST SUITE FAILED")
  else
    println("\n✅ ALL TESTS PASSED")

fun main() : <console,local<_>,div,exn> ()
  run-all-tests()