// Combined Effects in Koka
// Demonstrates composition of multiple effects and advanced patterns

import std/num/float64

// Multiple effect definitions
effect state<s>
  fun get() : s
  fun put(x : s) : ()

effect log
  fun log(msg : string) : ()

effect except
  ctl throw(msg : string) : a

effect reader<r>
  fun ask() : r

// Transaction effect for rollback
effect transaction
  ctl checkpoint() : ()
  ctl rollback() : a
  ctl commit() : ()

// Resource management effect
effect resource<r>
  fun acquire() : r
  fun release(r : r) : ()
  ctl use-resource(f : r -> a) : a

// Application state
struct app-state
  counter : int
  history : list<string>
  errors : list<string>

// Configuration
struct config
  debug : bool
  max-retries : int
  timeout : int

// Complex operation using multiple effects
fun complex-operation(value : int) : <state<app-state>,log,except,reader<config>> int
  val cfg = ask()
  
  log("Starting operation with value: " ++ value.show)
  
  val current = get()
  if value < 0 then
    throw("Negative value not allowed: " ++ value.show)
  
  val new-counter = current.counter + value
  
  if new-counter > 100 && !cfg.debug then
    throw("Counter overflow: " ++ new-counter.show)
  
  put(current(
    counter = new-counter,
    history = Cons("Added " ++ value.show, current.history)
  ))
  
  log("Operation completed, new counter: " ++ new-counter.show)
  new-counter

// Transactional operation
fun transactional-update(values : list<int>) : <state<app-state>,transaction,log,except> ()
  checkpoint()
  
  val initial = get()
  log("Starting transaction with " ++ values.length.show ++ " updates")
  
  fun process-values(vs : list<int>) : <state<app-state>,transaction,log,except> ()
    match vs
      Nil -> 
        commit()
        log("Transaction committed successfully")
      Cons(v, rest) ->
        val current = get()
        if v < 0 then
          log("Negative value detected, rolling back")
          rollback()
        
        put(current(counter = current.counter + v))
        
        if current.counter + v > 50 then
          log("Threshold exceeded, rolling back")
          rollback()
        
        process-values(rest)
  
  process-values(values)

// Resource-aware computation
fun with-file-operation() : <resource<string>,log,except> string
  use-resource fn(file)
    log("Processing file: " ++ file)
    if file == "" then
      throw("Invalid file handle")
    "Processed: " ++ file

// Effect polymorphism - works with any state type
fun modify-state(f : s -> s) : state<s> ()
  val current = get()
  put(f(current))

// Higher-order effect combinator
fun retry(max-attempts : int, action : () -> <except|e> a) : <log|e> maybe<a>
  fun attempt(n : int) : <log|e> maybe<a>
    if n > max-attempts then
      log("Max attempts reached")
      Nothing
    else
      handler
        return(x) Just(x)
        ctl throw(msg)
          log("Attempt " ++ n.show ++ " failed: " ++ msg)
          attempt(n + 1)
        { action() }
  
  attempt(1)

// Parallel-like effect composition
effect parallel
  ctl fork(task : () -> a) : a
  fun join-all(results : list<a>) : list<a>

fun parallel-compute() : <parallel,state<int>,log> list<int>
  val r1 = fork
    val s = get()
    put(s + 10)
    log("Task 1 completed")
    s + 10
  
  val r2 = fork
    val s = get()
    put(s + 20)
    log("Task 2 completed")
    s + 20
  
  val r3 = fork
    val s = get()
    put(s + 30)
    log("Task 3 completed")
    s + 30
  
  join-all([r1, r2, r3])

// Composed handlers
fun run-app(action : () -> <state<app-state>,log,except,reader<config>|e> a) : e maybe<(a, app-state, list<string>)>
  val initial-state = App-state(0, [], [])
  val config = Config(True, 3, 1000)
  var logs := []
  
  handler
    fun ask() config
    {
      handler
        fun log(msg)
          logs := Cons("[LOG] " ++ msg, logs)
        {
          handler
            return(x) Just(x)
            ctl throw(msg)
              logs := Cons("[ERROR] " ++ msg, logs)
              Nothing
            {
              handler
                var s := initial-state
                fun get() s
                fun put(x) s := x
                {
                  match action()
                    Just(result) -> Just((result, s, logs.reverse))
                    Nothing -> Nothing
                }
            }
        }
    }

// Transaction handler
fun run-transaction(action : () -> <state<app-state>,transaction,log|e> a) : <log|e> maybe<(a, app-state)>
  handler
    var s := App-state(0, [], [])
    var checkpoint-state := s
    fun get() s
    fun put(x) s := x
    {
      handler
        return(x) Just((x, s))
        ctl checkpoint()
          checkpoint-state := s
          log("Checkpoint created")
          resume(())
        ctl rollback()
          s := checkpoint-state
          log("Rolled back to checkpoint")
          Nothing
        ctl commit()
          log("Changes committed")
          resume(())
        { action() }
    }

// Resource handler
fun run-with-resource(action : () -> <resource<string>,log|e> a) : <log|e> a
  handler
    fun acquire()
      log("Resource acquired: file.txt")
      "file.txt"
    fun release(r)
      log("Resource released: " ++ r)
    ctl use-resource(f)
      val r = acquire()
      val result = f(r)
      release(r)
      resume(result)
    { action() }

// Parallel handler (simulated)
fun run-parallel(action : () -> <parallel,state<int>|e> a) : <state<int>|e> a
  handler
    ctl fork(task)
      resume(task())
    fun join-all(results)
      results
    { action() }

fun main() : <console,div> ()
  println("=== Complex Multi-Effect Operation ===")
  match run-app
    val v1 = complex-operation(10)
    val v2 = complex-operation(20)
    val v3 = complex-operation(15)
    v1 + v2 + v3
  with
    Just((result, final-state, logs)) ->
      println("Result: " ++ result.show)
      println("Final counter: " ++ final-state.counter.show)
      println("History: " ++ final-state.history.show)
      println("Logs:")
      logs.foreach fn(log)
        println("  " ++ log)
    Nothing ->
      println("Operation failed")
  
  println("\n=== Transactional Updates ===")
  var tx-logs := []
  handler
    fun log(msg) tx-logs := Cons(msg, tx-logs)
    {
      match run-transaction
        transactional-update([10, 20, 30])
      with
        Just((_, final-state)) ->
          println("Transaction successful")
          println("Final counter: " ++ final-state.counter.show)
        Nothing ->
          println("Transaction rolled back")
      
      println("Transaction logs:")
      tx-logs.reverse.foreach fn(l)
        println("  " ++ l)
    }
  
  println("\n=== Retry with Exceptions ===")
  var retry-logs := []
  var attempt-counter := 0
  handler
    fun log(msg) retry-logs := Cons(msg, retry-logs)
    {
      val result = retry(3)
        attempt-counter := attempt-counter + 1
        if attempt-counter < 3 then
          throw("Simulated failure #" ++ attempt-counter.show)
        else
          "Success on attempt " ++ attempt-counter.show
      
      match result
        Just(v) -> println("Retry succeeded: " ++ v)
        Nothing -> println("Retry failed after max attempts")
      
      println("Retry logs:")
      retry-logs.reverse.foreach fn(l)
        println("  " ++ l)
    }
  
  println("\n=== Resource Management ===")
  var resource-logs := []
  handler
    fun log(msg) resource-logs := Cons(msg, resource-logs)
    {
      val result = run-with-resource { with-file-operation() }
      println("Resource operation result: " ++ result)
      println("Resource logs:")
      resource-logs.reverse.foreach fn(l)
        println("  " ++ l)
    }
  
  println("\n=== Simulated Parallel Computation ===")
  var parallel-logs := []
  handler
    var state := 0
    fun get() state
    fun put(x) state := x
    {
      handler
        fun log(msg) parallel-logs := Cons(msg, parallel-logs)
        {
          val results = run-parallel { parallel-compute() }
          println("Parallel results: " ++ results.show)
          println("Final state: " ++ state.show)
          println("Parallel logs:")
          parallel-logs.reverse.foreach fn(l)
            println("  " ++ l)
        }
    }