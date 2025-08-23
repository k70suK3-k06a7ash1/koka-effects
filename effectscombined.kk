// Combined patterns in Koka
// Demonstrates composition of multiple programming patterns

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

// Transaction-like pattern
fun transactional-update() : <console,local<_>> bool
  println("Starting transaction...")
  var backup := 100
  var current := 100
  
  fun commit() : <local<_>,console> bool
    println("Committing transaction")
    backup := current
    True
    
  fun rollback() : <local<_>,console> bool
    println("Rolling back transaction")
    current := backup
    False
  
  // Simulate some work
  current := current + 50
  println("Updated value to: " ++ current.show)
  
  // Simulate a condition that causes rollback
  if current > 120 then
    rollback()
  else
    commit()

// Complex workflow combining multiple patterns
fun complex-workflow() : <console,local<_>,div> string
  println("=== Complex Workflow Start ===")
  
  // State management
  val state-result = stateful-computation()
  println("State result: " ++ state-result.show)
  
  // Logging with computation  
  val logged-result = logged-operation(state-result, 10)
  
  // Safe operations
  match safe-operation(logged-result, 5)
    Just(safe-result) -> 
      println("Safe operation succeeded: " ++ safe-result.show)
      // Reader pattern
      val config-result = compute-with-config(2, [safe-result])
      println("Config result: " ++ config-result.show)
      "Workflow completed successfully"
    Nothing ->
      println("Safe operation failed")
      "Workflow failed"

fun main() : <console,local<_>,div> ()
  println("=== Stateful Computation ===")
  val state = stateful-computation()
  println("Final state: " ++ state.show)
  
  println("\n=== Logged Operation ===")
  val logged = logged-operation(15, 25)
  println("Logged result: " ++ logged.show)
  
  println("\n=== Safe Operations ===")
  val safe1 = safe-operation(10, 2)
  val safe2 = safe-operation(10, 0)
  match safe1
    Just(v) -> println("Safe1 succeeded: " ++ v.show)
    Nothing -> println("Safe1 failed")
  match safe2  
    Just(v) -> println("Safe2 succeeded: " ++ v.show)
    Nothing -> println("Safe2 failed")
  
  println("\n=== Reader Pattern ===")
  val config = compute-with-config(3, [1, 2, 3, 4])
  println("Configured computation: " ++ config.show)
  
  println("\n=== Transactional Update ===")
  val trans = transactional-update()
  println("Transaction result: " ++ trans.show)
  
  println("\n=== Complex Workflow ===")
  val workflow = complex-workflow()
  println("Workflow result: " ++ workflow)