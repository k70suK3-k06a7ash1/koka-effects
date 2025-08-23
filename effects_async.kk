// Async/Await Effects in Koka
// Demonstrates how algebraic effects can model asynchronous operations

import std/num/float64

// Define async effect for non-blocking operations
effect async<a>
  ctl await(computation : () -> a) : a

// Simulated delay effect
effect delay
  fun sleep(ms : int) : ()

// Promise/Future-like structure
type promise<a>
  Pending(computation : () -> a)
  Resolved(value : a)

// Async task that simulates network request
fun fetch-data(id : int) : <async<string>,delay,console> string
  println("Starting fetch for id: " ++ id.show)
  val result = await
    sleep(100 * id)  // Simulate network delay
    "Data-" ++ id.show
  println("Completed fetch for id: " ++ id.show)
  result

// Parallel-like execution using async
fun fetch-multiple() : <async<list<string>>,delay,console> list<string>
  println("Fetching multiple items...")
  
  // Start all async operations
  val data1 = await { fetch-data(1) }
  val data2 = await { fetch-data(2) }
  val data3 = await { fetch-data(3) }
  
  [data1, data2, data3]

// Async with error handling
effect async-error
  ctl fail(msg : string) : a

fun safe-fetch(id : int) : <async<string>,async-error,delay,console> string
  if id < 0 then
    fail("Invalid ID: " ++ id.show)
  else
    await { fetch-data(id) }

// Chain async operations
fun process-data() : <async<int>,delay,console> int
  val raw = await
    sleep(100)
    "42"
  
  val parsed = await
    sleep(50)
    match raw.parse-int
      Just(n) -> n
      Nothing -> 0
  
  val result = await
    sleep(50)
    parsed * 2
  
  result

// Async map operation
fun async-map(xs : list<a>, f : a -> <async<b>|e> b) : <async<list<b>>|e> list<b>
  match xs
    Nil -> []
    Cons(x, xx) ->
      val result = await { f(x) }
      val rest = async-map(xx, f)
      Cons(result, rest)

// Simple async handler that executes immediately
fun run-async(action : () -> <async<a>,delay|e> a) : <delay|e> a
  handler
    ctl await(comp)
      resume(comp())
    { action() }

// Handler with simulated delay
fun run-with-delay(action : () -> <delay|e> a) : e a
  var total-delay := 0
  handler
    fun sleep(ms)
      total-delay := total-delay + ms
      println("[Simulated delay: " ++ ms.show ++ "ms, total: " ++ total-delay.show ++ "ms]")
    { 
      val result = action()
      println("[Total simulated time: " ++ total-delay.show ++ "ms]")
      result
    }

// Handler for async with error
fun run-async-safe(action : () -> <async<a>,async-error,delay|e> a) : <delay|e> maybe<a>
  handler
    return(x) Just(x)
    ctl fail(msg)
      println("Async operation failed: " ++ msg)
      Nothing
    {
      run-async { action() }
    }

// Example: Sequential vs "Concurrent" execution
fun sequential-example() : <console,delay> ()
  println("Sequential execution:")
  run-async
    val a = await { sleep(100); "A" }
    val b = await { sleep(100); "B" }
    val c = await { sleep(100); "C" }
    println("Results: " ++ [a, b, c].show)

// Async comprehension-like pattern
fun async-comprehension() : <async<int>,delay,console> int
  val x = await { sleep(50); 10 }
  val y = await { sleep(50); 20 }
  val z = await { sleep(50); 30 }
  x + y + z

fun main() : <console,div> ()
  println("=== Simple Async Example ===")
  run-with-delay
    run-async
      val result = fetch-data(1)
      println("Got: " ++ result)
  
  println("\n=== Multiple Async Operations ===")
  run-with-delay
    run-async
      val results = fetch-multiple()
      println("All results: " ++ results.show)
  
  println("\n=== Async with Error Handling ===")
  run-with-delay
    val result1 = run-async-safe { safe-fetch(5) }
    match result1
      Just(v) -> println("Success: " ++ v)
      Nothing -> println("Failed to fetch")
    
    val result2 = run-async-safe { safe-fetch(-1) }
    match result2
      Just(v) -> println("Success: " ++ v)
      Nothing -> println("Failed to fetch")
  
  println("\n=== Chained Async Operations ===")
  run-with-delay
    run-async
      val result = process-data()
      println("Processed result: " ++ result.show)
  
  println("\n=== Async Map ===")
  run-with-delay
    run-async
      val numbers = [1, 2, 3]
      val doubled = async-map(numbers) fn(x)
        await
          sleep(50 * x)
          x * 2
      println("Doubled numbers: " ++ doubled.show)
  
  println("\n=== Async Comprehension ===")
  run-with-delay
    run-async
      val sum = async-comprehension()
      println("Sum: " ++ sum.show)